#!/bin/bash
# This script requires the git CLI, sed, and rename in order to function
set -x

# Installs rename
mkdir /tmp/install-rename
curl -o /tmp/install-rename/utils.deb http://launchpadlibrarian.net/360849155/util-linux_2.31.1-0.4ubuntu3_amd64.deb
dpkg -x /tmp/install-rename/utils.deb /tmp/install-rename
PATH=$PATH://tmp/install-rename/usr/bin/

# Change to world-writeable path /tmp, so that sed works
cd /tmp

# Clones the templated repo to the provisioner execution environment via HTTPS
git clone https://oauth2:"$GITHUB_TOKEN"@github.com/"$OWNER"/"$WAYPOINT_PROJECT_NAME"
cd "$WAYPOINT_PROJECT_NAME"

# Finds all usages of %%wp_project%% in files and replaces with our project name
find . -type f -not -path '*/\.git/*' -exec sed -i.bak "s/%%[Ww]p_project%%/$WAYPOINT_PROJECT_NAME/g" {} \;

# Finds all usages of %%wp_project_lower%% in files and replaces with our project name, but lowercased
find . -type f -not -path '*/\.git/*' -exec sed -i.bak "s/%%wp_project_lower%%/$WAYPOINT_PROJECT_NAME_LOWER/g" {} \;

# Finds all usages of %%gh_org%% in the files and replaces with our GitHub owner name
find . -type f -not -path '*/\.git/*' -exec sed -i.bak "s/%%gh_org%%/$OWNER/g" {} \;

# Finds all usages of %%aws_region%% in the files and replaces with our AWS region
find . -type f -not -path '*/\.git/*' -exec sed -i.bak "s/%%aws_region%%/$AWS_REGION/g" {} \;

# Finds all usages of %%role_arn%% in the files and replaces with our role ARN
find . -type f -not -path '*/\.git/*' -exec sed -i.bak "s/%%aws_region%%/ROLE_ARN/g" {} \;

# Cleans up backup files from sed
find . -name "*.bak" -type f -delete

# Finds and renames directories with our project name where __wp_project__ is found
find . -depth -type d -execdir rename.ul __wp_project__ $WAYPOINT_PROJECT_NAME {} +

# Finds and renames files with our project name where __wp_project__ is found
find . -type f -exec rename.ul __wp_project__ $WAYPOINT_PROJECT_NAME {} +

# git needs a user for the commit
git config user.name "$GIT_USER"
git config user.email "$GIT_EMAIL"

# Add, commit, and push!
git add .
git commit -m "init: Render repo template with Waypoint project name."
git push origin