# pullstack-sandbox: the tools that open untrusted artifacts. Built once by sandbox.sh; runs with no network.
FROM mcr.microsoft.com/dotnet/sdk:8.0
RUN apt-get update \
 && apt-get install -y --no-install-recommends unzip p7zip-full xz-utils binutils file xxd python3 python3-pip \
 && rm -rf /var/lib/apt/lists/* \
 && curl -fsSL -o /tmp/upx.tar.xz https://github.com/upx/upx/releases/download/v5.2.1/upx-5.2.1-amd64_linux.tar.xz \
 && echo '402162aad30af47e60dbd767fb2e64ca394ace9727ba1f40283641f1d1b91657  /tmp/upx.tar.xz' | sha256sum -c - \
 && tar -xJf /tmp/upx.tar.xz -C /usr/local/bin --strip-components=1 upx-5.2.1-amd64_linux/upx && rm /tmp/upx.tar.xz \
 && pip install --no-cache-dir --break-system-packages pyinstxtractor-ng \
 && dotnet tool install --tool-path /opt/ilspy ilspycmd --version 9.1.0.7988 \
 && chmod -R a+rX /opt/ilspy
ENV PATH=/opt/ilspy:$PATH HOME=/tmp DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1
COPY unpack.py /opt/pullstack/unpack.py
