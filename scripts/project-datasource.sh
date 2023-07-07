#!/bin/bash

# Connect the newly created github repo as a datasource to the existing waypoint project

# NOTE(izaak): we should eventually use the waypoint terraform provisioner to do this,
# and it would be better to configure this via the github apps authentication so we don't
# need to rely on a static access token.

if [[ -z "$WAYPOINT_SERVER_TOKEN" ]]
then
	echo "Required variable WAYPOINT_SERVER_TOKEN is unset"
	exit 1
fi

if [[ -z "$WAYPOINT_PROJECT_NAME" ]]
then
	echo "Required variable WAYPOINT_PROJECT_NAME is unset"
	exit 1
fi

if [[ -z "$OWNER" ]]
then
	echo "Required variable OWNER (representing the github org or parent user) is unset"
	exit 1
fi

if [[ -z "$GITHUB_TOKEN" ]]
then
	echo "Required variable GITHUB_TOKEN (representing the github org or parent user) is unset"
	exit 1
fi

if [[ -z "$GIT_USER" ]]
then
	echo "Required variable GIT_USER is unset"
	exit 1
fi


# Install the latest Waypoint CLI
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install waypoint

# Create a CLI context to hook up to the HCP Waypoint server
waypoint context create \
  -server-addr=api.hashicorp.cloud:443 \
  -server-auth-token="$WAYPOINT_SERVER_TOKEN" \
  -server-require-auth=true \
  -server-platform="hcp" \
  -set-default \
  hcp-waypoint

waypoint context verify

# Configure the project datasource settings
waypoint project apply \
  -data-source=git \
  -git-url=https://github.com/${OWNER}/${WAYPOINT_PROJECT_NAME} \
  -git-auth-type=basic \
  -git-username=$GIT_USER \
  -git-password=$GITHUB_TOKEN \
  $WAYPOINT_PROJECT_NAME

echo "Waypoint project $WAYPOINT_PROJECT_NAME git datasource configured"