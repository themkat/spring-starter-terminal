#!/bin/bash

BACK_TITLE='Spring Initializer Terminal Edition'

STARTER_METADATA=$(curl -s -H 'Accept: application/json' https://start.spring.io)

BUILD_TOOL=$(echo $STARTER_METADATA | jq -r '.type.default')
LANGUAGE=$(echo $STARTER_METADATA | jq -r '.language.default')
SPRING_BOOT_VERSION=$(echo $STARTER_METADATA | jq -r '.bootVersion.default')
JAVA_VERSION=$(echo $STARTER_METADATA | jq -r '.javaVersion.default')
GROUP_ID=$(echo $STARTER_METADATA | jq -r '.groupId.default')
ARTIFACT_ID=$(echo $STARTER_METADATA | jq -r '.artifactId.default')
DESCRIPTION=$(echo $STARTER_METADATA | jq -r '.description.default')
DEPENDENCIES=""

function artifactSettings () {
	while [ 1 ]
	do
		ACTION=$(dialog --stdout --backtitle "$BACK_TITLE" --no-cancel --inputmenu "Artifact settings" 0 0 10 "Group id:" "$GROUP_ID" "Artifact id:" "$ARTIFACT_ID" "Description:" "$DESCRIPTION")
		
		# not renaming, so OK was selected. gtf back to the menu
		if [ -z $(echo $ACTION | grep RENAMED)]
		then
			break
		fi

		SELECTIONS=$(echo ${ACTION:8} | sed 's/: /:+/g')
		SELECTED_TYPE=$(echo $SELECTIONS | cut -d + -f1)
		SELECTED_VALUE=$(echo $SELECTIONS | cut -d + -f2)
	    case $SELECTED_TYPE in
			"Group id:")
				GROUP_ID=$SELECTED_VALUE
				;;
			"Artifact id:")
				ARTIFACT_ID=$SELECTED_VALUE
				;;
			"Description:")
				DESCRIPTION=$SELECTED_VALUE
		esac
	done
	
}


function dependencyManagement () {
	# TODO: simple search..?
	# TODO: could --help-button be used 
	# TODO: how should descriptions be viewed?

	# get all the possible selections, default to not selected
	DEPENDENCY_LIST=$(echo $STARTER_METADATA | jq '.dependencies.values | map(.values[]) | map(.id, .name)[]' | sed '{N;s/\n/ /;}' | sed 's/$/ off/')
	
	# turn our currently selected dependencies on
	for SELECTED_DEPENDENCY in $(echo "$DEPENDENCIES" | tr ',' '\n')
	do
	    DEPENDENCY_LIST=$(echo "$DEPENDENCY_LIST" | sed -E "s/(\"$SELECTED_DEPENDENCY\" .*) off/\1 on/")
	done

	# make it into a format that dialog works with (without newlines)
	DEPENDENCY_LIST=$(echo $DEPENDENCY_LIST | tr '\n' ' ')
	
	DEPENDENCIES=$(eval "dialog --stdout --backtitle \"$BACK_TITLE\" --checklist \"Choose dependencies\" 0 0 0 $DEPENDENCY_LIST" | sed 's/ /,/g')
}

function _transformChoicesToDialogRadioOptions() {
	# I iz stupid, so usually prefer to use sed in smaller blocks like this. Probably a better way to do them in one. I prefer readability :)
	CHOICES=$1
	CURRENT_SELECTION=$2
	echo "$CHOICES" | sed 'n;s/$/ off/' | sed '{N;s/\n/ /;}' | sed -E "s/(\"$CURRENT_SELECTION\" .*) off/\1 on/" | tr '\n' ' '
}

function changeBuildTool() {
	BUILD_TOOL_SELECTIONS=$(echo $STARTER_METADATA | jq '.type.values | map(.id, .name)[]')
	RADIO_OPTIONS=$(_transformChoicesToDialogRadioOptions "$BUILD_TOOL_SELECTIONS" "$BUILD_TOOL")
	BUILD_TOOL=$(eval "dialog --stdout --backtitle \"$BACK_TITLE\" --radiolist 'Select language' 0 0 0 $RADIO_OPTIONS")
}

function changeSpringBootVersion() {
	SPRING_BOOT_VERSION_SELECTIONS=$(echo $STARTER_METADATA | jq '.bootVersion.values | map(.id, .name)[]')
	RADIO_OPTIONS=$(_transformChoicesToDialogRadioOptions "$SPRING_BOOT_VERSION_SELECTIONS" "$SPRING_BOOT_VERSION")
	SPRING_BOOT_VERSION=$(eval "dialog --stdout --backtitle \"$BACK_TITLE\" --radiolist 'Select language' 0 0 0 $RADIO_OPTIONS")
}

function changeLanguage () {
	LANGUAGE_SELECTIONS=$(echo $STARTER_METADATA | jq '.language.values | map(.id, .name)[]')
	RADIO_OPTIONS=$(_transformChoicesToDialogRadioOptions "$LANGUAGE_SELECTIONS" $LANGUAGE)
    LANGUAGE=$(eval "dialog --stdout --backtitle \"$BACK_TITLE\" --radiolist 'Select language' 0 0 0 $RADIO_OPTIONS")
}

function changeJavaVersion () {
	JAVA_VERSION_SELECTIONS=$(echo $STARTER_METADATA | jq '.javaVersion.values | map(.id, .name)[]' | sed 'n;s/^\"/\"Java /g')
	RADIO_OPTIONS=$(_transformChoicesToDialogRadioOptions "$JAVA_VERSION_SELECTIONS" "$JAVA_VERSION")
	JAVA_VERSION=$(eval "dialog --stdout --backtitle \"$BACK_TITLE\" --radiolist 'Select Java version' 0 0 0 $RADIO_OPTIONS")
}


while [ 1 ]
do
	CHOICE=$(dialog --stdout --backtitle "$BACK_TITLE" --title "Select option" --menu "Artifact information:\nGroup id:            $GROUP_ID\nArtifact id:         $ARTIFACT_ID\n\nBuild tool:          $BUILD_TOOL\nLanguage:            $LANGUAGE\nSpring Boot version: $SPRING_BOOT_VERSION\nJava version:        $JAVA_VERSION\n" 0 0 0 "a" "Artifact settings" "b" "Change build tool" "s" "Change Spring Boot version" "l" "Change language" "j" "Change Java version" "d" "Manage dependencies" "c" "Create project")

	if [ $? -ne 0 ]
	then 
		echo "Cancel selected, exiting..."
		exit 1
	fi
	
	case $CHOICE in
		"a")
			artifactSettings
			;;
		"b")
			changeBuildTool
			;;
		"s")
			changeSpringBootVersion
			;;
		"l")
			changeLanguage
			;;
		"j")
			changeJavaVersion
			;;
		"d")
			dependencyManagement
			;;
		"c")
			# If network issues then we get an empty folder... "Neat" :P 
			mkdir $ARTIFACT_ID 
			curl -s https://start.spring.io/starter.tgz -d language=$LANGUAGE \
				 -d javaVersion=$JAVA_VERSION \
				 -d type=$BUILD_TOOL \
				 -d bootVersion=$SPRING_BOOT_VERSION \
				 -d groupId=$GROUP_ID \
				 -d artifactId=$ARTIFACT_ID \
				 -d description=$DESCRIPTION \
				 -d dependencies=$DEPENDENCIES \
				| tar --directory $ARTIFACT_ID -zxf - && \
				echo "Spring Boot project now in $ARTIFACT_ID directory... Happy Hacking! :)"
			exit 0
			;;
	esac
done
