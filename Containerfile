###############################################################################
# PROJECT NAME CONFIGURATION
###############################################################################
# Name: finpilot
#
# IMPORTANT: Change "finpilot" above to your desired project name.
# This name should be used consistently throughout the repository in:
#   - Justfile: export image_name := env("IMAGE_NAME", "your-name-here")
#   - README.md: # your-name-here (title)
#   - artifacthub-repo.yml: repositoryID: your-name-here
#   - custom/ujust/README.md: localhost/your-name-here:stable (in bootc switch example)
#
# The project name defined here is the single source of truth for your
# custom image's identity. When changing it, update all references above
# to maintain consistency.
###############################################################################

###############################################################################
# MULTI-STAGE BUILD ARCHITECTURE
###############################################################################
# This Containerfile follows the Bluefin architecture pattern as implemented in
# @projectbluefin/distroless. The architecture layers OCI containers together:
#
# 1. Context Stage (ctx) - Combines resources from:
#    - Local build scripts and custom files
#    - @projectbluefin/common - Desktop configuration shared with Aurora 
#    - @ublue-os/brew - Homebrew integration
#
# 2. Base Image Options:
#    - `ghcr.io/ublue-os/silverblue-main:latest` (Fedora and GNOME)
#    - `ghcr.io/ublue-os/base-main:latest` (Fedora and no desktop 
#    - `quay.io/centos-bootc/centos-bootc:stream10 (CentOS-based)` 
#
# See: https://docs.projectbluefin.io/contributing/ for architecture diagram
###############################################################################

# Context stage - combine local and imported OCI container resources
FROM scratch AS ctx

COPY build /build
COPY custom /custom
# Copy from OCI containers to distinct subdirectories to avoid conflicts
# Note: Renovate can automatically update these :latest tags to SHA-256 digests for reproducibility
COPY --from=ghcr.io/projectbluefin/common:latest@sha256:b8fe93b16674a547b4cf38493af19caa484d9575956fc3be04ca3d10faec23ff /system_files /oci/common
COPY --from=ghcr.io/ublue-os/brew:latest@sha256:ca91068f51ce663d495ccfc829352d6621ec95f6c7db447ade55023b222f9762 /system_files /oci/brew
# Uncomment if you need the akmods kernel stuff
# COPY --from=ghcr.io/ublue-os/akmods:coreos-stable-43@sha256:4ec52946a8012117c91f28407fafef4654bab09133a35991d195040a1161c2dd / /oci/akmods
# Copy from submodule.  We put it under /oci for convenience
COPY tr-osforge/reusable_scripting /oci/tr-osforge

# Base Image (substitute with your chosen base image)
FROM ghcr.io/ublue-os/silverblue-main:latest


## Example alternative base images;
## Note that there is no desktop included
# FROM ghcr.io/ublue-os/base-main:latest    
# FROM quay.io/centos-bootc/centos-bootc:stream10
# FROM quay.io/gnome_infrastructure/gnome-build-meta:gnomeos-nightly

# These are used in the build scripts
ARG IMAGE_NAME
ARG TAG

### MODIFICATIONS
## Make modifications desired in your image and install packages by modifying the build scripts.
## The following RUN directive mounts the ctx stage which includes:
##   - Local build scripts from /build
##   - Local custom files from /custom
##   - Files from @projectbluefin/common at /oci/common
##   - Files from @projectbluefin/branding at /oci/branding
##   - Files from @ublue-os/artwork at /oci/artwork
##   - Files from @ublue-os/brew at /oci/brew
##
##  Bluebuild modules are available by running /tmp/scripts/run_module.sh
##  See https://blue-build.org/how-to/minimal-setup/
##
##  See build/build.sh for more info on how the build scripts work

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=ghcr.io/blue-build/modules:latest,src=/modules,dst=/tmp/modules,rw \
    --mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:latest,src=/scripts/,dst=/tmp/scripts/ \
    /ctx/build/build.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
