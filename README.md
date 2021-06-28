Kinly Terraform ###PROJECT### project
======================================

This project is used to deploy ###PROJECT### resources within the GCP projects.

CI/CD
-----
Currently no CI/CD is being used yet.

Manual
------
For manual deployment, a terraform-run.sh script is provided.
You can run this script by providing it the desired region, environment and action.
NB: To be able to run this script, you need to have the "Service Account Token Creator" role assigned to you on the terraform SA of the videocloud-###PROJECT###-<customer>-<env> project.

Before running the script, you need to be authenticated on GCP. You can do this by running the following gcloud command:
```
gcloud auth application-default login
```

Example script usage:
```
./scripts/terraform-run.sh -s euw2 -e dev -c shared -a init
```

A Makefile has been added to make it easier to run the terraform script:
```
make help

make videocloud-###PROJECT###-shared-dev-euw2-init
make videocloud-###PROJECT###-shared-dev-euw2-plan
make videocloud-###PROJECT###-shared-dev-euw2-apply
```

### Advanced usage

If you're absolutely sure you want to deploy your changes, you can also run:
```
make videocloud-###PROJECT###-shared-dev-euw2-all

```

If you need to run terraform yourself (eg. to make state file manupilations), you can run the `bash` target which will spawn a new shell with the right environment variables already set:
```
make videocloud-###PROJECT###-shared-dev-euw2-bash
```
