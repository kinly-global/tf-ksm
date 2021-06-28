#!/bin/bash

(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ $sourced -ne 1 ]; then
	echo This script is not to be called directly. Error.
	exit 1
fi

fail () {
	echo $*
	exit 1
}

set_env () {
	[ -n "$customer" ] || fail "No customer detected, please set this."
	[ -n "$environment" ] || fail "No environment detected, please set this."
	[ -n "$slice" ] || fail "No slice/region detected, please set this."

	export CUSTOMER=${customer}
	export ENVIRONMENT=${environment}
	export SLICE=${slice}

	export TF_WORKSPACE="${CUSTOMER}-${ENVIRONMENT}-${SLICE}"

	export TF_STATE_BUCKET="videocloud-${PROJECT}-${CUSTOMER}-${ENVIRONMENT}-tf"

	export SA_GCP_PROJECT="videocloud-cicd-${CUSTOMER}-${ENVIRONMENT}"
	export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT="tf-vc-${PROJECT}-${CUSTOMER}-${ENVIRONMENT}@${SA_GCP_PROJECT}.iam.gserviceaccount.com"
}
