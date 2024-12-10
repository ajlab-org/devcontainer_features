#!/bin/sh
#
#
#
check_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
        ubuntu | debian)
            echo "System detected: $ID"
            ;;
        arch)
            echo "System detected: Arch Linux"
            ;;
        *)
            echo "Unsupported system: $ID"
            exit 1
            ;;
        esac
    else
        echo "Unsupported system: Unable to detect OS."
        exit 1
    fi
}

install_gcp_cli() {
    # Determine system and install dependencies
    if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
        apt-get update
        apt-get install -y curl tar jq gnupg

        # Download and install Google Cloud SDK
        tmp_dir=$(mktemp -d -t gcp-downloads-XXXX)
        echo ":: Fetching latest release info from Google Cloud SDK components manifest..."
        gcp_manifest_url="https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json"
        case "${VERSION}" in
        latest) version=$(curl -sSL "${gcp_manifest_url}" | jq -r ".version") ;;
        *) version="${VERSION}" ;;
        esac

        gcp_base_url="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads"
        gcp_sdk_file="google-cloud-cli-${version}-linux-${architecture}.tar.gz"
        gcp_sdk_url="${gcp_base_url}/${gcp_sdk_file}"

        echo ":: Downloading Google Cloud SDK ${version}..."
        curl -sSL "${gcp_sdk_url}" | tar -xz -C "${tmp_dir}"

        echo ":: Moving Google Cloud SDK to /usr/local..."
        mv "${tmp_dir}/google-cloud-sdk" /usr/local/

        echo ":: Installing Google Cloud SDK ${version}..."
        /usr/local/google-cloud-sdk/install.sh --quiet --path-update true

        echo ":: Cleaning up..."
        rm -rf "${tmp_dir}"
    elif [ "$ID" = "arch" ]; then
        # Arch Linux-specific installation remains as-is
        check_and_install_packages curl tar
        # Existing Arch-specific logic here...
    else
        echo "Unsupported system: $ID"
        exit 1
    fi
}
