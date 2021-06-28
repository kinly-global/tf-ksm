#!/bin/bash

set -eo pipefail

# Make sure we can run from anywhere and still have the correct paths
SCRIPT="${BASH_SOURCE[0]}"
DIR="$( cd "$( dirname "${SCRIPT}" )" >/dev/null 2>&1 && pwd )"
TERRAFORM_SRC_DIR="${DIR}/../src"

usage() {
	echo "Usage: $SCRIPT -c|--customer <customer> -e|--environment <env_abbr> -s|--slice <slice> -a|--action (init|plan|apply|bash)"
}

init () {
	cd "${TERRAFORM_SRC_DIR}"
	rm -rf .terraform
	TF_WORKSPACE= terraform init -backend-config="bucket=${TF_STATE_BUCKET}"

	terraform validate
	cd -
}

plan() {
	cd "${TERRAFORM_SRC_DIR}"
	terraform validate
	terraform plan -out="${TF_WORKSPACE}.plan"
	cd -
}

apply() {
	# Uncomment once CI/CD is implemented
	#echo -e "WARNING: You should not run apply locally unless you have a really good reason for this!"
	#echo -e "Are you sure you want to continue? (yes|no)"
	ACCEPT="yes"
	#read ACCEPT

	if [[ "${ACCEPT}" == "yes" ]]
	then
		cd "${TERRAFORM_SRC_DIR}"
		terraform validate
		terraform apply "${TF_WORKSPACE}.plan"
		rm "${TF_WORKSPACE}.plan"
		cd -
	else
		echo -e "Aborting"
		exit 0
	fi
}

destroy() {
	echo -e "WARNING: All resources deployed with this Terraform script will be destroyed"
	echo -e "Are you sure you want to continue? (yes|no)"
	read ACCEPT

	if [[ "${ACCEPT}" == "yes" ]]
	then
		cd "${TERRAFORM_SRC_DIR}"
		terraform destroy
		cd -
	else
		echo -e "Aborting"
		exit 0
	fi
}

while [ "$1" != "" ]; do
	case $1 in
		-c | --customer )
			shift
			customer="$1"
			;;
		-e | --environment )
			shift
			environment="$1"
			;;
		-s | --slice )
			shift
			slice="$1"
			;;
		-a | --action )
			shift
			action="$1"
			;;
		-h | --help )
			usage
			exit
			;;
		* )
			usage
			exit 1
	esac
	shift
done

source "${DIR}/project_env.sh"
source "${DIR}/set_env.sh"

set_env

[ -n "$TF_WORKSPACE" ] && [ -n "$TF_STATE_BUCKET" ] || fail "ERROR: TF_WORKSPACE or TF_STATE_BUCKET not properly set by set_env function. Abort!"

case $action in
	init )
		init
		;;
	plan )
		plan
		;;
	apply)
		apply
		;;
	destroy)
		destroy
		;;
	bash)
		cd "${TERRAFORM_SRC_DIR}"
		# TODO: sanity check if init was already run against current state bucket
		env PS1="Type exit when done with terraform shell.\n[\[\e[0;38;5;233;48;5;31;22m$TF_WORKSPACE\e[m|\e[0;38;5;231;48;5;22m$ENVIRONMENT\e[m|\e[0;38;5;1m$PROJECT\e[m|\e[0;38;5;2m${SLICE:-none}\e[m]\w> " PROMPT_COMMAND="history -a" bash --norc -i
		cd -
		;;
	*)
	    usage
		exit 1
esac

