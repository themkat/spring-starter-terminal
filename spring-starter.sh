#!/bin/bash

STARTER_METADATA=$(curl -s -H 'Accept: application/json' https://start.spring.io)

BUILD_TOOL=$(echo $STARTER_METADATA | jq -r '.type.default')
LANGUAGE=$(echo $STARTER_METADATA | jq -r '.language.default')
SPRING_BOOT_VERSION=$(echo $STARTER_METADATA | jq -r '.bootVersion.default')
JAVA_VERSION=$(echo $STARTER_METADATA | jq -r '.javaVersion.default')
GROUP_ID=$(echo $STARTER_METADATA | jq -r '.groupId.default')
ARTIFACT_ID=$(echo $STARTER_METADATA | jq -r '.artifactId.default')
DESCRIPTION=$(echo $STARTER_METADATA | jq -r '.description.default')


function artifactSettings () {
	while [ 1 ]
	do
		ACTION=$(dialog --stdout --backtitle 'Spring Initializer Terminal Edition' --inputmenu "Artifact settings" 0 0 10 "Group id:" "$GROUP_ID" "Artifact id:" "$ARTIFACT_ID" "Description:" "$DESCRIPTION")

		if [ $? -ne 0]
		then
			break
		fi

		# TODO: finish it. See if we get RENAMED something back.
	done
	
}


function dependencyManagement () {
	# TODO: simple search..

	# TODO: could --help-button be used 
	
	# TODO: how should descriptions be viewed?
	# TODO: make the choices "persistent" between "saves"
	DEPENDENCY_LIST=$(echo $STARTER_METADATA | jq '.dependencies.values | map(.values[]) | map(.id, .name)[]' | sed '0~2 s/$/\noff/g' | tr '\n' ' ')
	eval "dialog --stdout --backtitle \"Spring Initializer Terminal Edition\" --checklist \"Choose dependencies\" 0 0 0 $DEPENDENCY_LIST"
}


function changeLanguage () {
	LANGUAGE_SELECTIONS=$(echo $STARTER_METADATA | jq '.language.values | map(.id, .name)[]')
    eval "dialog --stdout --backtitle 'Spring Initializer Terminal Edition' --radiolist 'Select language' 0 0 0 $(echo "$LANGUAGE_SELECTIONS" | sed '0~2 s/$/ off/g' | tr '\n' ' ')"
}


# select java version screen
# (without anything selected so far...)
function changeJavaVersion () {
	JAVA_VERSION_SELECTIONS=$(echo $STARTER_METADATA | jq '.javaVersion.values | map(.id, .name)[]' | sed '0~2 s/^\"/\"Java /g')
	# TODO: find a better way to determine the last number
	NUM_JAVA_VERSIONS=$(expr $(echo "$JAVA_VERSION_SELECTIONS" | wc -l) / 2)
	eval "dialog --stdout --backtitle 'Spring Initializer Terminal Edition' --radiolist 'Select Java version' 0 0 $NUM_JAVA_VERSIONS $(echo "$JAVA_VERSION_SELECTIONS" | sed '0~2 s/$/ off/g' | tr '\n' ' ')"
}



# flow:
# main menu with all main information
# menu items:
# - change groupId/artifactId/description
# - Change build tool (maven/gradle)
# - Change language
# - Change Java Version
# - Manage dependencies
# - Create project


while [ 1 ]
do
	CHOICE=$(dialog --stdout --backtitle 'Spring Initializer Terminal Edition' --title "Select option" --menu "Group id:            $GROUP_ID\nArtifact id:         $ARTIFACT_ID\n\nBuild tool:          $BUILD_TOOL\nLanguage:            $LANGUAGE\nSpring Boot version: $SPRING_BOOT_VERSION\nJava version:        $JAVA_VERSION\n" 0 0 0 "a" "Artifact settings" "p" "Change project information" "l" "Change language" "j" "Change Java version" "d" "Manage dependencies" "c" "Create project")

	if [ $? -ne 0 ]
	then 
		echo "Cancel selected, exiting..."
		exit 1
	fi
	
	case $CHOICE in
		"a")
			artifactSettings
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
	esac
done
