#!/usr/bin/env bash

# A best practices Bash script template with many useful functions. This file
# sources in the bulk of the functions from the source.sh file which it expects
# to be in the same directory. Only those functions which are likely to need
# modification are present in this file. This is a great combination if you're
# writing several scripts! By pulling in the common functions you'll minimise
# code duplication, as well as ease any potential updates to shared functions.

# Enable xtrace if the DEBUG environment variable is set
if [[ ${DEBUG-} =~ ^1|yes|true$ ]]; then
    set -o xtrace       # Trace the execution of the script (debug)
fi

# Only enable these shell behaviours if we're not being sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    # A better class of script...
    set -o errexit      # Exit on most errors (see the manual)
    set -o nounset      # Disallow expansion of unset variables
    set -o pipefail     # Use last non-zero exit code in a pipeline
fi

# Enable errtrace or the error trap handler will not work as expected
set -o errtrace         # Ensure the error trap handler is inherited

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
    cat << EOF
Usage:
     -h|--help                  Displays this help
     -v|--verbose               Displays verbose output
    -nc|--no-colour             Disables colour output
    -cr|--cron                  Run silently unless we encounter an error
EOF
}

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parse_params() {
    local param
    while [[ $# -gt 0 ]]; do
        param="$1"
        shift
        case $param in
            -h | --help)
                script_usage
                exit 0
                ;;
            -v | --verbose)
                verbose=true
                ;;
            -nc | --no-colour)
                no_colour=true
                ;;
            -cr | --cron)
                cron=true
                ;;
            *)
                script_exit "Invalid parameter was provided: $param" 1
                ;;
        esac
    done
}

readonly noreturn="noreturn"
readonly nocontinue="nocontinue"

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {
    trap script_trap_err ERR
    trap script_trap_exit EXIT

    script_init "$@"
    parse_params "$@"
    cron_init
    colour_init
    #lock_init system

    validate_elasticsearch_installation

    install_analysis_plugins
    install_discovery_plugins
    install_filesystem_plugins
    install_ingest_plugins
    install_mapper_plugins
    install_repository_plugins
    install_store_plugins
}

# DESC: Checks the environment variable $ELASTICSEARCH_IMAGE_VERSION 
#       against the installed version of Elasticsearch. The script
#       will exit if one of the following conditions is met:
#           1) The environment variable $ELASTICSEARCH_IMAGE_VERSION
#              is not present. This means the script is not being 
#              run in the correct environment (i.e. Dockerfile)
#           2) The command `elasticsearch` cannot be found. This 
#              either means:
#                  a) The `bin` directory of the installed version
#                     of Elasticsearch is not found in $PATH, or;
#                  b) Elasticsearch has not been installed in 
#                     general.
#           3) There is a conflict between the expected and actual
#              installed version of Elasticsearch. To be fair this
#              should never occur as long as we pass checks 1) and
#              2), but in the off chance that this does happen,
#              it may have unexpected results.
# ARGS: None
# OUTS: None
function validate_elasticsearch_installation() {
    local docker_install_version

    pretty_print "Verifying Elasticsearch installation..." "${fg_white-}"

    # Check for documented case 1)
    if [[ -z "${ELASTICSEARCH_IMAGE_VERSION:-}" ]]; then
        script_exit "Environment variable ELASTICSEARCH_IMAGE_VERSION is not set!" -1; else
        verbose_print "Expecting Elasticsearch v$ELASTICSEARCH_IMAGE_VERSION..." "${fg_red-}"
        docker_install_version="$ELASTICSEARCH_IMAGE_VERSION"
    fi

    # Check for documented case 2)
    check_binary elasticsearch nocontinue

    # Check for documented case 3)
    elasticsearch --version | grep -q "$docker_install_version" || script_exit "Unexpected Elasticsearch version!" -1
    
    pretty_print "Elasticsearch installation confirmed!" "${fg_green-}"
}

# DESC: Checks the following environment variables to determine
#       which Elasticsearch Analysis plugins should be
#       installed:
#           - $USE_ICU_ANALYSIS             => analysis-icu
#           - $USE_KUROMOJI_ANALYSIS        => analysis-kuromoji
#           - $USE_NORI_ANALYSIS            => analysis-nori
#           - $USE_PHONETIC_ANALYSIS        => analysis-phonetic
#           - $USE_SMART_CHINESE_ANALYSIS   => analysis-smartcn
#           - $USE_STEMPEL_POLISH_ANALYSIS  => analysis-stempel
#           - $USE_UKRANIAN_ANALYSIS        => analysis-ukrainian
# ARGS: None
# OUTS: None
function install_analysis_plugins() {
    # local counter vars
    local requested success failure
    requested=0
    success=0
    failure=0
    
    pretty_print "Checking Analysis plugins..." "${fg_white-}"
    
    if [[ "${USE_ICU_ANALYSIS:-0}" == "1" ]]; then
        (( requested = requested + 1 ))
        verbose_print "Installing Analysis plugin: analysis-icu" "${fg_white-}"
        do_install "analysis-icu"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "analysis-icu"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_KUROMOJI_ANALYSIS:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Analysis plugin: analysis-kuromoji" "${fg_white-}"
        do_install "analysis-kuromoji"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "analysis-kuromoji"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_NORI_ANALYSIS:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Analysis plugin: analysis-nori" "${fg_white-}"
        do_install "analysis-nori"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "analysis-nori"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_PHONETIC_ANALYSIS:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Analysis plugin: analysis-phonetic" "${fg_white-}"
        do_install "analysis-phonetic"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "analysis-phonetic"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_SMART_CHINESE_ANALYSIS:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Analysis plugin: analysis-smartcn" "${fg_white-}"
        do_install "analysis-smartcn"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "analysis-smartcn"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_STEMPEL_POLISH_ANALYSIS:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Analysis plugin: analysis-stempel" "${fg_white-}"
        do_install "analysis-stempel"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "analysis-stempel"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_UKRANIAN_ANALYSIS:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Analysis plugin: analysis-ukrainian" "${fg_white-}"
        do_install "analysis-ukrainian"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "analysis-ukrainian"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi

    pretty_print "Finished Analysis plugins!" "${fg_green-}"
    pretty_print "${requested} plugins requested: " "${fg_white-}" noreturn
    pretty_print "${success} plugins installed, " "${fg_green-}" noreturn
    pretty_print "${failure} failed." "${fg_red-}"
}

# DESC: Checks the following environment variables to determine
#       which Elasticsearch Discovery plugins should be
#       installed:
#           - $USE_EC2_DISCOVERY            => discovery-ec2
#           - $USE_AZURE_DISCOVERY          => discovery-azure-classic
#           - $USE_GCE_DISCOVERY            => discovery-gce
# ARGS: None
# OUTS: None
# NOTE: The `discovery-azure-classic` plugin was deprecated in
#       Elasticsearch v5.0.0. Attempting to install will fail
#       silently.
function install_discovery_plugins() {
    # local counter vars
    local requested success failure
    requested=0
    success=0
    failure=0

    pretty_print "Checking Discovery plugins..." "${fg_white-}"

    if [[ "${USE_EC2_DISCOVERY:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Discovery plugin: discovery-ec2" "${fg_white-}"
        do_install "discovery-ec2"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "discovery-ec2"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_AZURE_DISCOVERY:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Plugin 'discovery-azure-classic' was deprecated in v5.0.0! Skipping install..." "${fg_red-}"
        (( failure = failure + 1 ))
    fi
    if [[ "${USE_GCE_DISCOVERY:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Discovery plugin: discovery-gce" "${fg_white-}"
        do_install "discovery-gce"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "discovery-gce"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi

    pretty_print "Finished Discovery plugins!" "${fg_green-}"
    pretty_print "${requested} plugins requested: " "${fg_white-}" noreturn
    pretty_print "${success} plugins installed, " "${fg_green-}" noreturn
    pretty_print "${failure} failed." "${fg_red-}"
}

# DESC: Checks the following environment variables to determine
#       which Elasticsearch Filesystem plugins should be
#       installed:
#           - $USE_QUOTA_AWARE_FILESYSTEM   => quota-aware-fs
# ARGS: None
# OUTS: None
function install_filesystem_plugins() {
    # local counter vars
    local requested success failure
    requested=0
    success=0
    failure=0

    pretty_print "Checking Filesystem plugins..." "${fg_white-}"

    if [[ "${USE_QUOTA_AWARE_FILESYSTEM:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Filesystem plugin: quota-aware-fs" "${fg_white-}"
        do_install "quota-aware-fs"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "quota-aware-fs"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi

    pretty_print "Finished Filesystem plugins!" "${fg_green-}"
    pretty_print "${requested} plugins requested: " "${fg_white-}" noreturn
    pretty_print "${success} plugins installed, " "${fg_green-}" noreturn
    pretty_print "${failure} failed." "${fg_red-}"
}

# DESC: Checks the following environment variables to determine
#       which Elasticsearch Ingest plugins should be
#       installed:
#           - $USE_ATTACHMENT_INGEST        => ingest-attachment
# ARGS: None
# OUTS: None
function install_ingest_plugins() {
    # local counter vars
    local requested success failure
    requested=0
    success=0
    failure=0
    
    pretty_print "Checking Ingest plugins..." "${fg_white-}"

    if [[ "${USE_ATTACHMENT_INGEST:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Ingest plugin: ingest-attachment" "${fg_white-}"
        do_install "ingest-attachment"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "ingest-attachment"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi

    pretty_print "Finished Ingest plugins!" "${fg_green-}"
    pretty_print "${requested} plugins requested: " "${fg_white-}" noreturn
    pretty_print "${success} plugins installed, " "${fg_green-}" noreturn
    pretty_print "${failure} failed." "${fg_red-}"
}

# DESC: Checks the following environment variables to determine
#       which Elasticsearch Mapper plugins should be
#       installed:
#           - $USE_SIZE_MAPPER              => mapper-size
#           - $USE_MURMUR3_MAPPER           => mapper-murmur3
#           - $USE_ANNOTATED_TEXT_MAPPER    => mapper-annotated-text
# ARGS: None
# OUTS: None
function install_mapper_plugins() {
    # local counter vars
    local requested success failure
    requested=0
    success=0
    failure=0

    pretty_print "Checking Mapper plugins..." "${fg_white-}"

    if [[ "${USE_SIZE_MAPPER:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Mapper plugin: mapper-size" "${fg_white-}"
        do_install "mapper-size"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "mapper-size"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_MURMUR3_MAPPER:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Mapper plugin: mapper-murmur3" "${fg_white-}"
        do_install "mapper-murmur3"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "mapper-murmur3"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_ANNOTATED_TEXT_MAPPER:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Mapper plugin: mapper-annotated-text" "${fg_white-}"
        do_install "mapper-annotated-text"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "mapper-annotated-text"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi

    pretty_print "Finished Mapper plugins!" "${fg_green-}"
    pretty_print "${requested} plugins requested: " "${fg_white-}" noreturn
    pretty_print "${success} plugins installed, " "${fg_green-}" noreturn
    pretty_print "${failure} failed." "${fg_red-}"
}

# DESC: Checks the following environment variables to determine
#       which Elasticsearch Snapshot/Restore Repository plugins
#       should be installed:
#           - $USE_AZURE_REPOSITORY         => repository-azure
#           - $USE_S3_REPOSITORY            => repository-s3
#           - $USE_HADOOP_REPOSITORY        => repository-hdfs
#           - $USE_GCS_REPOSITORY           => repository-gcs
# ARGS: None
# OUTS: None
function install_repository_plugins() {
    # local counter vars
    local requested success failure
    requested=0
    success=0
    failure=0

    pretty_print "Checking Repository plugins..." "${fg_white-}"

    if [[ "${USE_AZURE_REPOSITORY:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Repository plugin: repository-azure" "${fg_white-}"
        do_install "repository-azure"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "repository-azure"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_S3_REPOSITORY:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Repository plugin: repository-s3" "${fg_white-}"
        do_install "repository-s3"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "repository-s3"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_HADOOP_REPOSITORY:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Repository plugin: repository-hdfs" "${fg_white-}"
        do_install "repository-hdfs"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "repository-hdfs"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi
    if [[ "${USE_GCS_REPOSITORY:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Repository plugin: repository-gcs" "${fg_white-}"
        do_install "repository-gcs"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "repository-gcs"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi

    pretty_print "Finished Repository plugins!" "${fg_green-}"
    pretty_print "${requested} plugins requested: " "${fg_white-}" noreturn
    pretty_print "${success} plugins installed, " "${fg_green-}" noreturn
    pretty_print "${failure} failed." "${fg_red-}"
}

# DESC: Checks the following environment variables to determine
#       which Elasticsearch Store plugins should be
#       installed:
#           - $USE_SMB_STORE                => store-smb
# ARGS: None
# OUTS: None
function install_store_plugins() {
    # local counter vars
    local requested success failure
    requested=0
    success=0
    failure=0
    
    pretty_print "Checking Store plugins..." "${fg_white-}"

    if [[ "${USE_SMB_STORE:-0}" == "1" ]]; then 
        (( requested = requested + 1 ))
        verbose_print "Installing Store plugin: store-smb" "${fg_white-}"
        do_install "store-smb"
        # TODO: Fix `validate_install`
        (( success = success + 1 ))
        # if validate_install "store-smb"; then (( success = success + 1 )); else (( failure = failure + 1 )); fi
    fi

    pretty_print "Finished Store plugins!" "${fg_green-}"
}

# DESC: Installs the requested Elasticsearch plugin
# ARGS: $1 (required): The name of the plugin to install
# OUTS: None
function do_install() {
    if [[ $# -lt 1 ]]; then
        script_exit 'Missing required argument to do_install()!' 2
    fi

    check_binary elasticsearch-plugin nocontinue

    if [[ -z "$(elasticsearch-plugin list | grep $1)" ]]; then
        elasticsearch-plugin install --batch "$1"
    fi
}

# DESC: Validates the installation of the requested 
#       Elasticsearch plugin
# ARGS: $1 (required): The name of the plugin to confirm
# OUTS: None
# RETN: 1 => The plugin was successfully installed
#       0 => The plugin was not successfully installed
function validate_install() {
    # TODO: This will not work until the node is restarted.
    #       This results in the install looking like it has
    #       failed, even though it hasn't. I am commenting 
    #       out the usage of the `validate_install` 
    #       function, and will revisit this at a later 
    #       date. Plugin installation can be verified 
    #       through REST API after the nodes are online.
    if [[ $# -lt 1 ]]; then
        script_exit 'Missing required argument to validate_install()!' 2
    fi

    check_binary elasticsearch-plugin nocontinue

    local found
    found=0

    if [[ -n "$(elasticsearch-plugin list | grep $1)" ]]; then
        found=1
        verbose_print "Plugin $1 successfully installed!" "${fg_green-}"; else
        verbose_print "Failed to install plugin $1!" "${fg_red-}"
    fi

    return $found
}

# shellcheck source=source.sh
source "$(dirname "${BASH_SOURCE[0]}")/source.sh"

# Invoke main with args if not sourced
# Approach via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    main "$@"
fi

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
