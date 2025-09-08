# prow-scripts

This repo is used to run CI tests in https://github.com/openshift/release

This repo uses [krkn-hub](https://github.com/krkn-chaos/krkn-hub) templates 


# New Scenarios

1. Create a krkn-hub folder exists for the scenario; see [here](https://krkn-chaos.dev/docs/developers-guide/editing-krkn-hub/) for helpful hints on how to configure it
2. Create a prow_run.sh in prow-scripts like https://github.com/redhat-chaos/prow-scripts/blob/main/cpu-hog/prow_run.sh
3. Fork and clone https://github.com/openshift/release and create a new branch
4. Create folder for the scenario in https://github.com/openshift/release/tree/master/ci-operator/step-registry/redhat-chaos including commands file, ref, and metadata-ref
5. Create a new test step in one of the version files [here](https://github.com/openshift/release/tree/master/ci-operator/config/redhat-chaos/prow-scripts) with the use of the ref configured in step 3
6. Create PR with these changes to openshift/release
7. PR will give list of jobs that can be run
8. Run ‘/pj-rehearse <job_name>”
9. See interacting with running job: https://docs.ci.openshift.org/docs/how-tos/interact-with-running-jobs/
10. Can set up slack alerts of tests if needed (only works when PR gets merged on periodic jobs)
https://docs.ci.openshift.org/docs/how-tos/notification/



Updated: 13:17 Sep 08 2025
