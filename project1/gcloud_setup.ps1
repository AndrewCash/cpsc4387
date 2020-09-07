 param (
    [string]$project = $( Read-Host "Input GCP project:" ),
    [string]$region = "us-central1"
 )

# Move to the correct project
gcloud config set project $project

# Commands to enable the necessary APIs.
$confirmation = Read-Host "Do you want to enable the necessary APIs at this time? (y/N)"
if ($confirmation -eq 'y')
{
    gcloud services enable compute.googleapis.com
    gcloud services enable cloudfunctions.googleapis.com
    gcloud services enable cloudbuild.googleapis.com
    gcloud services enable pubsub.googleapis.com
    gcloud services enable run.googleapis.com
    gcloud services enable cloudscheduler.googleapis.com
    gcloud services enable runtimeconfig.googleapis.com
}

# Create a service account for the project
$confirmation = Read-Host "Do you want to create the service account at this time? (y/N)"
if ($confirmation -eq 'y')
{
    gcloud iam service-accounts create myservice --display-name "Service Account for the CPSC 4387-5387 Projects"
    gcloud projects add-iam-policy-binding $project --member = serviceAccount:myservice@"$project".iam.gserviceaccount.com --role = 'roles/owner'
    gcloud projects add-iam-policy-binding $project --member = serviceAccount:myservice@"$project".iam.gserviceaccount.com --role = 'roles/pubsub.admin'
}

# Create pubsub topics
$confirmation = Read-Host "Do you want to create the pubsub topics for cloud functions at this time? (y/N)"
if ($confirmation -eq 'y') {
    gcloud pubsub topics create stop-all-servers
}

# Create project defaults
$confirmation = Read-Host "Do you want to set project defaults at this time? (y/N)"
if ($confirmation -eq 'y') {
    gcloud beta runtime-config configs create "myconfig" --description "Project constants for cloud functions and main app"
    gcloud beta runtime-config configs variables set "project" $project --config-name "myconfig"
    gcloud beta runtime-config configs variables set "region" "us-central1" --config-name "myconfig"
    gcloud beta runtime-config configs variables set "zone" "us-central1-a" --config-name "myconfig"
}

# Create the maintenance cloud functions
$confirmation = Read-Host "Before creating the cloud functions, you need to have this mirrored repo set up. Do you want to continue? (y/N)"
if ($confirmation -eq 'y')
{
    gcloud functions deploy --quiet function-stop-all-servers `
        --region=$region `
        --memory=256MB `
        --entry-point=cloud_fn_stop_all_servers `
        --runtime=python37 `
        --source=https://source.developers.google.com/projects/$project/repos/github/moveable-aliases/master/paths/project1/cloud-functions `
        --service-account=myservice@"$project".iam.gserviceaccount.com `
        --timeout=540s `
        --trigger-topic=stop-all-servers
}

# Create cloud schedules
$confirmation = Read-Host "Do you want to create cloud schedules for cloud functions at this time? (y/N)"
if ($confirmation -eq 'y') {
    $tz = Read-Host "What is your timezone? (America/Chicago) "
    if ($tz -eq '') {
        $tz = "America/Chicago"
    }

    gcloud scheduler jobs create pubsub job-stop-all-servers --schedule="0 * * * *" --topic=stop-all-servers --message-body=Hello!
}