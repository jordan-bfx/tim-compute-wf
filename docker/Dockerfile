# Combined runtime for the Nextflow processes in this workflow.
# Dorado is pinned to ONT's published image digest; the Conda packages are
# pinned to the latest stable BioConda releases checked on 2026-11-11.
FROM nanoporetech/dorado@sha256:832c995858ac5418f4357d87c31faf8259e4dba45201c78216704baa05d651c6

ARG MICROMAMBA_VERSION=2.10.0
ENV MAMBA_ROOT_PREFIX=/opt/micromamba

# procps provides `ps`, which Nextflow uses for task resource metrics.
# Install bash as required by Nextflow's task wrapper.
RUN env -u LD_LIBRARY_PATH apt-get update \
    && env -u LD_LIBRARY_PATH apt-get install -y --no-install-recommends bash ca-certificates curl procps bzip2 \
    && rm -rf /var/lib/apt/lists/*

# Install pinned samtools and modkit packages from Bioconda.
RUN curl -Ls "https://micro.mamba.pm/api/micromamba/linux-64/${MICROMAMBA_VERSION}" \
    | tar -xj -C /tmp bin/micromamba \
    && install -m 0755 /tmp/bin/micromamba /usr/local/bin/micromamba \
    && rm -rf /tmp/bin \
    && micromamba create --yes --prefix /opt/tools \
        --channel conda-forge \
        --channel bioconda \
        --strict-channel-priority \
        samtools=1.25 \
        ont-modkit=0.6.4 \
    && micromamba clean --all --yes

ENV PATH=/opt/tools/bin:${PATH}
