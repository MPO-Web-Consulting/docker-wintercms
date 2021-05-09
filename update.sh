#!/bin/bash
set -e

#####################
### Dependency check

if ! hash curl 2>&-; then echo "Error: curl is required" && exit 1; fi
if ! hash jq 2>&-; then echo "Error: jq is required" && exit 1; fi
if ! hash sha1sum 2>&-; then { if ! hash openssl 2>&-; then echo "Error: openssl/sha1sum is required" && exit 1; fi } fi

##############
### Functions

function check_winter {
  # CORE_HASH="$WINTERCMS_CORE_HASH";

  # curl -X POST -fsS --connect-timeout 15 --url https://api.github.com/repos/wintercms/winter/releases/latest \
  #  -F "build=$CORE_BUILD" -F "core=$CORE_HASH" -F "plugins=a:0:{}" -F "server=$WINTERCMS_SERVER_HASH" -F "edge=$EDGE" \
  #   | jq '. | { build: .core.build, hash: .core.hash, update: .update, updates: .core.updates }' || exit 1

  # curl -fsS --connect-timeout 15 https://api.github.com/repos/wintercms/winter/releases/latest | jq -r '. | { name: .name, tag: .tag_name, hash: $CORE_HASH}' || exit 1;
  curl -fsS --connect-timeout 15 https://api.github.com/repos/wintercms/winter/releases/latest | jq -r '. | { name: .name, tag: .tag_name}' || exit 1;
}

function update_checksum {
  if [ -z "$1" ]; then
    echo "Error: Invalid slug. Aborting..." && exit 1;
  else
    local SLUG=$1;
  fi

  local ARCHIVE="wintercms-$SLUG.tar.gz"
  curl -o $ARCHIVE -fS#L --connect-timeout 15 https://github.com/wintercms/winter/archive/refs/tags/$SLUG.tar.gz || exit 1;
  if hash sha1sum 2>&-; then
    sha1sum $ARCHIVE | awk '{print $1}'
  elif hash openssl 2>&-; then
    openssl sha1 $ARCHIVE | awk '{print $2}'
  else
    echo "Error: Could not generate checksum. Aborting" && exit 1;
  fi
  rm $ARCHIVE
}

function update_checksum_for_commit {
  if [ -z "$1" ]; then
    echo "Error: Invalid slug. Aborting..." && exit 1;
  else
    local SLUG=$1;
  fi

  local ARCHIVE="wintercms-$SLUG.tar.gz"
  curl -o $ARCHIVE -fS#L --connect-timeout 15 https://github.com/wintercms/winter/archive/$SLUG.tar.gz || exit 1;
  if hash sha1sum 2>&-; then
    sha1sum $ARCHIVE | awk '{print $1}'
  elif hash openssl 2>&-; then
    openssl sha1 $ARCHIVE | awk '{print $2}'
  else
    echo "Error: Could not generate checksum. Aborting" && exit 1;
  fi
  rm $ARCHIVE
}

function update_dockerfiles {

  local current_tag="$STABLE_BUILD"
  local checksum=$STABLE_CHECKSUM
  # local hash=$STABLE_CORE_HASH
  local build=$STABLE_BUILD
  local ext=""

  [ "$1" = "develop" ] && local ext=".develop"

  local phpVersions=( php7.*/ )

  phpVersions=( "${phpVersions[@]%/}" )

  for phpVersion in "${phpVersions[@]}"; do
    phpVersionDir="$phpVersion"
    phpVersion="${phpVersion#php}"

    if [ "$phpVersion" == "7.4" ]; then
      gd_config="docker-php-ext-configure gd --with-jpeg --with-webp"
      zip_config="docker-php-ext-configure zip --with-zip"
    else
      gd_config="docker-php-ext-configure gd --with-png-dir --with-jpeg-dir --with-webp-dir"
      zip_config="docker-php-ext-configure zip --with-libzip"
    fi

    for variant in apache fpm; do
      dir="$phpVersionDir/$variant"
      mkdir -p "$dir"

      if [ "$variant" == "apache" ]; then
        extras="RUN a2enmod rewrite"
        cmd="apache2-foreground"
      elif [ "$variant" == "fpm" ]; then
        extras=""
        cmd="php-fpm"
      fi

      sed \
        -e '/^#.*$/d' -e '/^  #.*$/d' \
        -e 's!%%WINTERCMS_TAG%%!'"$current_tag"'!g' \
        -e 's!%%WINTERCMS_CHECKSUM%%!'"$checksum"'!g' \
        -e 's!%%WINTERCMS_CORE_HASH%%!'"$hash"'!g' \
        -e 's!%%WINTERCMS_CORE_BUILD%%!'"$build"'!g' \
        -e 's!%%WINTERCMS_DEVELOP_COMMIT%%!'"$GITHUB_LATEST_COMMIT"'!g' \
        -e 's!%%WINTERCMS_DEVELOP_CHECKSUM%%!'"$GITHUB_LATEST_CHECKSUM"'!g' \
        -e 's!%%PHP_VERSION%%!'"$phpVersion"'!g' \
        -e 's!%%PHP_GD_CONFIG%%!'"$gd_config"'!g' \
        -e 's!%%PHP_ZIP_CONFIG%%!'"$zip_config"'!g' \
        -e 's!%%VARIANT%%!'"$variant"'!g' \
        -e 's!%%VARIANT_EXTRAS%%!'"$extras"'!g' \
        -e 's!%%CMD%%!'"$cmd"'!g' \
        Dockerfile$ext.template > "$dir/Dockerfile$ext"

    done
  done
}

function copy_entrypoint_config {
  local phpVersions=( php7.*/ )

  phpVersions=( "${phpVersions[@]%/}" )

  for phpVersion in "${phpVersions[@]}"; do
    phpVersionDir="$phpVersion"
    phpVersion="${phpVersion#php}"

    for variant in apache fpm; do
      dir="$phpVersionDir/$variant"
      mkdir -p "$dir"
      cp -a docker-wn-entrypoint "$dir/docker-wn-entrypoint"
      cp -a config "$dir/."
    done
  done
}

function join {
  local sep="$1"; shift
  local out; printf -v out "${sep//%/%%}\`%s\`" "$@"
  echo "${out#$sep}"
}

function update_buildtags {

  defaultPhpVersion='php7.2'
  defaultVariant='apache'

  phpFolders=( php7.*/ )
  phpVersions=()
  # process in descending order
  for (( idx=${#phpFolders[@]}-1 ; idx>=0 ; idx-- )) ; do
    phpVersions+=( "${phpFolders[idx]%/}" )
  done

  for phpVersion in "${phpVersions[@]}"; do
    for variant in apache fpm; do
      dir="$phpVersion/$variant"
      [ -f "$dir/Dockerfile" ] || continue

      fullVersion="$(cat "$dir/Dockerfile" | awk '$1 == "ENV" && $2 == "WINTERCMS_CORE_BUILD" { print $3; exit }')"
      fullVersion=build.$fullVersion

      versionAliases=()
      versionAliases+=( $fullVersion latest )

      phpVersionVariantAliases=( "${versionAliases[@]/%/-$phpVersion-$variant}" )
      phpVersionVariantAliases=( "${phpVersionVariantAliases[@]//latest-/}" )

      fullAliases=( "${phpVersionVariantAliases[@]}" )

      if [ "$phpVersion" = "$defaultPhpVersion" ]; then
        if [ "$variant" = "$defaultVariant" ]; then
          fullAliases+=( "${versionAliases[@]}" )
        fi
      fi

      tagsMarkdown+="- $(join ', ' "${fullAliases[@]}"): [$dir/Dockerfile](https://github.com/mik-p/docker-wintercms/blob/master/$dir/Dockerfile)\n"

      # Build develop tags
      [ -f "$dir/Dockerfile.develop" ] || continue

      developAliases=( develop )

      phpDevelopVersionVariantAliases=( "${developAliases[@]/%/-$phpVersion-$variant}" )
      phpDevelopVersionVariantAliases=( "${phpDevelopVersionVariantAliases[@]//latest-/}" )

      fullDevelopAliases=( "${phpDevelopVersionVariantAliases[@]}" )

      if [ "$phpVersion" = "$defaultPhpVersion" ]; then
        if [ "$variant" = "$defaultVariant" ]; then
          fullDevelopAliases+=( "${developAliases[@]}" )
        fi
      fi
      developTagsMarkdown+="- $(join ', ' "${fullDevelopAliases[@]}"): [$dir/Dockerfile.develop](https://github.com/mik-p/docker-wintercms/blob/master/$dir/Dockerfile.develop)\n"

    done
  done

  # Recreate README.md
  sed '/## Supported Tags/q' README.md \
   | sed -e "s/CMS Build v[0-9]*.[0-9]*.[0-9]*/CMS Build $STABLE_BUILD/" \
   | sed -e "s/CMS%20Build-v[0-9]*.[0-9]*.[0-9]*/CMS%20Build-$STABLE_BUILD/" > README_TMP.md
  echo -e "\n${tagsMarkdown[*]}" >> README_TMP.md
  echo -e "\n### Develop Tags" >> README_TMP.md
  echo -e "\n${developTagsMarkdown[*]}" >> README_TMP.md
  sed -n -e '/## Quick Start/,$p' README.md >> README_TMP.md
  mv README_TMP.md README.md
}

function update_repo {
  # commit changes to repository
  echo " - Committing changes to repo..."
  git add php*/*/Dockerfile* README.md version

  if [ "$STABLE_UPDATE" -eq 1 ]; then
    git commit -m "Build $STABLE_BUILD" -m "Automated update"
  elif [ "$DEVELOP_UPDATE" -eq 1 ]; then
    git commit -m "Develop update" -m "Automated update"
  fi

  git push
}

#########################
### Command line options

while true; do
  case "$1" in
    --force)   FORCE=1; shift ;;
    --push)    PUSH=1; shift ;;
    --rewrite) REWRITE_ONLY=1; shift ;;
    *)
      break
  esac
done

########
### Run

echo "Automat: `date`"

[ "$PUSH" ] && echo ' - Commit changes'
# Load cached version if not forced
[ "$FORCE" ] && echo ' - Force update' || source version
[ "$REWRITE_ONLY" ] && echo ' - Rewriting Dockerfiles and README'

echo " - Querying Winter CMS repo for latest..."
LATEST_STABLE_RELEASE=$(check_winter)

if [ $(echo "$LATEST_STABLE_RELEASE" | jq -r '.name') == $WINTERCMS_BUILD ]; then
  STABLE_UPDATE=0
  STABLE_BUILD=$WINTERCMS_BUILD
  # STABLE_CORE_HASH=$WINTERCMS_CORE_HASH
  STABLE_CHECKSUM=$WINTERCMS_CHECKSUM
  echo "    No STABLE build updates ($WINTERCMS_BUILD)";
else
  STABLE_UPDATE=1
  STABLE_BUILD=$(echo "$LATEST_STABLE_RELEASE" | jq -r '.name')
  # STABLE_CORE_HASH=$(echo "$STABLE_RESPONSE" | jq -r '.hash')
  echo "    New STABLE build ($WINTERCMS_BUILD -> $STABLE_BUILD)";
  echo "     STABLE Build: $STABLE_BUILD"
  # echo "     STABLE commit hash: $STABLE_CORE_HASH"
  echo " - Generating new checksum..."
  STABLE_TAG=$(echo "$LATEST_STABLE_RELEASE" | jq -r '.tag')
  STABLE_CHECKSUM=$(update_checksum "$STABLE_TAG")
  echo "     GitHub Tag $STABLE_TAG | $STABLE_CHECKSUM"
fi

echo " - Fetching GitHub repository for latest tag..."
GITHUB_LATEST_TAG=$( curl -fsS --connect-timeout 15 https://api.github.com/repos/wintercms/winter/tags | jq -r '.[0] | .name') || exit 1;
[ -z "$GITHUB_LATEST_TAG" ] && exit 1 || echo "    Latest repo tag: $GITHUB_LATEST_TAG";

echo " - Fetching latest commit on develop branch..."
GITHUB_LATEST_COMMIT=$( curl -fsS --connect-timeout 15 https://api.github.com/repos/wintercms/winter/commits/develop | jq -r '.sha') || exit 1;
[ -z "$GITHUB_LATEST_COMMIT" ] && exit 1 || echo "    Latest commit hash: $GITHUB_LATEST_COMMIT";

if [ "$GITHUB_LATEST_COMMIT" != "$WINTERCMS_DEVELOP_COMMIT" ]; then
  DEVELOP_UPDATE=1
  echo "    New DEVELOP commit";
  echo "     SHA: $GITHUB_LATEST_COMMIT"
  echo " - Generating develop checksum..."
  GITHUB_LATEST_CHECKSUM=$(update_checksum_for_commit $GITHUB_LATEST_COMMIT)
else
  DEVELOP_UPDATE=0
  GITHUB_LATEST_CHECKSUM=$WINTERCMS_DEVELOP_CHECKSUM
fi

echo " - Copying entrypoint and config..."
copy_entrypoint_config

if [ "$REWRITE_ONLY" -eq 1 ] || [ "$STABLE_UPDATE" -eq 1 ] || [ "$DEVELOP_UPDATE" -eq 1 ]; then
  echo " - Setting build values..."
  echo "    WINTERCMS_BUILD: $STABLE_BUILD" && echo "WINTERCMS_BUILD=$STABLE_BUILD" > version
  # echo "    WINTERCMS_CORE_HASH: $STABLE_CORE_HASH" && echo "WINTERCMS_CORE_HASH=$STABLE_CORE_HASH" >> version
  echo "    WINTERCMS_CHECKSUM: $STABLE_CHECKSUM" && echo "WINTERCMS_CHECKSUM=$STABLE_CHECKSUM" >> version
  echo "    WINTERCMS_DEVELOP_COMMIT: $GITHUB_LATEST_COMMIT" && echo "WINTERCMS_DEVELOP_COMMIT=$GITHUB_LATEST_COMMIT" >> version
  echo "    WINTERCMS_DEVELOP_CHECKSUM: $GITHUB_LATEST_CHECKSUM" && echo "WINTERCMS_DEVELOP_CHECKSUM=$GITHUB_LATEST_CHECKSUM" >> version
  update_dockerfiles && update_dockerfiles develop
  update_buildtags
  [ "$PUSH" ] && update_repo || echo ' - No changes committed.'

  if [ "$SLACK_WEBHOOK_URL" ]; then
    echo -n " - Posting update to Slack..."
    curl -X POST -fsS --connect-timeout 15 --data-urlencode "payload={
      'text': 'Winter CMS Build $STABLE_BUILD | Develop $GITHUB_LATEST_COMMIT',
    }" $SLACK_WEBHOOK_URL
    echo -e ""
  fi
fi

echo " - Update complete." && exit 0;
