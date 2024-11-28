#!/usr/bin/env bash
## <CAN BE RUN STANDALONE>
## <REQUIRES: ${GITHUB_TOKEN} ${HF_TOKEN}>
# source <(curl -qfsSL "https://raw.githubusercontent.com/Azathothas/Toolpacks-BinCache-Importer/main/.github/scripts/gen_sync_aarch64-Linux.sh")
##
#-------------------------------------------------------#
##ENV
export TZ="UTC"
SYSTMP="$(dirname $(mktemp -u))" && export SYSTMP="${SYSTMP}"
TMPDIR="$(mktemp -d)" && export TMPDIR="${TMPDIR}" ; echo -e "\n[+] Using TEMP: ${TMPDIR}\n"
if [ -z "${HOST_TRIPLET+x}" ] || [ -z "${HOST_TRIPLET}" ]; then
 HOST_TRIPLET="$(uname -m)-$(uname -s)" && export HOST_TRIPLET="${HOST_TRIPLET}"
fi
HF_REPO="https://huggingface.co/datasets/pkgforge/bincache/resolve/main" && export HF_REPO="${HF_REPO}"
HF_REPO_DL="${HF_REPO}/${HOST_TRIPLET}" && export HF_REPO_DL="${HF_REPO_DL}"
#-------------------------------------------------------#

#-------------------------------------------------------#
##Main (bin.pkgforge.dev)
curl -qfsSL "https://bin.pkgforge.dev/aarch64/METADATA.json" -o "${SYSTMP}/METADATA.json.src"
if [ "$(jq '. | length' "${SYSTMP}/METADATA.json.src")" -gt 1000 ]; then
   cat "${SYSTMP}/METADATA.json.src" |\
   jq -r '
     .[] | 
     "[[bin]]\n" +
     "pkg = \"\(.name)\"\n" +
     "pkg_family = \"\(.pkg_family // .name | gsub("\\.no_strip"; ""))\"\n" +
     "pkg_name = \"\(.name | gsub("\\.no_strip"; ""))\"\n" +
     "description = \"\(.description)\"\n" +
     "note = \"\(.note)\"\n" +
     "version = \"" + (if has("repo_version") then (if .repo_version == "" then "latest" else .repo_version end) else "latest" end) + "\"\n" +
     "download_url = \"" + (.download_url | sub("https://bin.ajam.dev/aarch64_arm64_Linux/"; "https://bincache.pkgforge.dev/aarch64/")) + "\"\n" +
     "size = \"\(.size | ascii_upcase)\"\n" +
     "bsum = \"\(.b3sum)\"\n" +
     "shasum = \"\(.sha256)\"\n" +
     "build_date = \"\(.build_date)\"\n" +
     "src_url = \"\(.repo_url)\"\n" +
     "homepage = \"\(.web_url)\"\n" +
     "build_script = \"\(.build_script)\"\n" +
     "build_log = \"https://bincache.pkgforge.dev/aarch64/\(.name).log.txt\"\n" +
     "category = \"" + (if .repo_topics == "" then "utility" else .repo_topics end) + "\"\n" +
     "icon = \"" + (if .icon == null or .icon == "" then "https://bincache.pkgforge.dev/aarch64/bin.default.png" else .icon end) + "\"\n" +
     "provides = \"\(.extra_bins)\"\n" +
     "snapshots = [" +
       ( .snapshots // [] | map("\"" + . + "\"") | join(", ")) +
     "]\n"
   ' 2>/dev/null > "${SYSTMP}/aarch64-Linux-METADATA.toml"
   validtoml "${SYSTMP}/aarch64-Linux-METADATA.toml"
   ##BaseUtils (bin.pkgforge.dev)
   curl -qfsSL "https://bin.pkgforge.dev/aarch64/Baseutils/METADATA.json" |\
   jq -r '
     .[] | 
     "[[base]]\n" +
     "pkg = \"\(.name)\"\n" +
     "pkg_family = \"\(.pkg_family // .name | gsub("\\.no_strip"; ""))\"\n" +
     "pkg_name = \"\(.name | gsub("\\.no_strip"; ""))\"\n" +
     "description = \"\(.description)\"\n" +
     "note = \"\(.note)\"\n" +
     "version = \"" + (if has("repo_version") then (if .repo_version == "" then "latest" else .repo_version end) else "latest" end) + "\"\n" +
     "download_url = \"" + (.download_url | sub("https://bin.ajam.dev/aarch64_arm64_Linux/"; "https://bincache.pkgforge.dev/aarch64/")) + "\"\n" +
     "size = \"\(.size | ascii_upcase)\"\n" +
     "bsum = \"\(.b3sum)\"\n" +
     "shasum = \"\(.sha256)\"\n" +
     "build_date = \"\(.build_date)\"\n" +
     "src_url = \"\(.repo_url)\"\n" +
     "homepage = \"\(.web_url)\"\n" +
     "build_script = \"\(.build_script)\"\n" +
     "build_log = \"https://bincache.pkgforge.dev/aarch64/" + (if (.build_script | type) == "string" and (.build_script | test(".*/.*\\..+")) then (.build_script | split("/") | last | split(".") | .[0]) else .name end) + ".log\"\n" +
     "category = \"" + (if .repo_topics == "" then "utility" else .repo_topics end) + "\"\n" +
     "icon = \"" + (if .icon == null or .icon == "" then "https://bincache.pkgforge.dev/aarch64/base.default.png" else .icon end) + "\"\n" +
     "provides = \"\(.extra_bins)\"\n" +
     "snapshots = [" +
       ( .snapshots // [] | map("\"" + . + "\"") | join(", ")) +
     "]\n"
   ' 2>/dev/null >> "${SYSTMP}/aarch64-Linux-METADATA.toml"
   ##Pkgs (pkg.pkgforge.dev)
   curl -qfsSL "https://pkgcache.pkgforge.dev/aarch64/METADATA.min.json" |\
   jq -r '
     .[] |
     "[[pkg]]\n" +
     "pkg = \"\(.name)\"\n" +
     "pkg_family = \"\(.pkg_family // .name)\"\n" +
     "pkg_id = \"\(.bin_id)\"\n" +
     "pkg_name = \"\(.bin_name)\"\n" +
     "description = \"\(.description)\"\n" +
     "note = \"\(.note)\"\n" +
     "version = \"\(.version)\"\n" +
     "download_url = \"\(.download_url)\"\n" +
     "size = \"\(.size | ascii_upcase)\"\n" +
     "bsum = \"\(.bsum)\"\n" +
     "shasum = \"\(.shasum)\"\n" +
     "build_date = \"\(.build_date)\"\n" +
     "repology = \"\(.repology)\"\n" +
     "src_url = \"\(.src_url)\"\n" +
     "homepage = \"\(.web_url)\"\n" +
     "build_script = \"\(.build_script)\"\n" +
     "build_log = \"\(.build_log)\"\n" +
     "appstream = \"\(.appstream)\"\n" +
     "category = \"\(.category)\"\n" +
     "desktop = \"\(.desktop)\"\n" +
     "icon = \"" + (if .icon == null or .icon == "" then "https://pkgcache.pkgforge.dev/aarch64/pkg.default.png" else .icon end) + "\"\n" +
     "screenshots = [" +
       ( .screenshots // [] | map("\"" + . + "\"") | join(", ")) +
     "]\n" +
     "provides = \"\(.provides)\"\n" +
     "snapshots = [" +
       ( .snapshots // [] | map("\"" + . + "\"") | join(", ")) +
     "]\n"
   ' 2>/dev/null >> "${SYSTMP}/aarch64-Linux-METADATA.toml"
   ##Validate & Merge
   validtoml "${SYSTMP}/aarch64-Linux-METADATA.toml"
   taplo check "${SYSTMP}/aarch64-Linux-METADATA.toml" && cp "${SYSTMP}/aarch64-Linux-METADATA.toml" "${TMPDIR}/METADATA.AIO.toml"
   cat "${TMPDIR}/METADATA.AIO.toml" | yj -tj | jq 'to_entries | sort_by(.key) | from_entries' > "${TMPDIR}/METADATA.AIO.json"
   if jq --exit-status . "${TMPDIR}/METADATA.AIO.json" >/dev/null 2>&1; then
     cat "${TMPDIR}/METADATA.AIO.json" | jq . > "${TMPDIR}/METADATA.json"
     cp -fv "${TMPDIR}/METADATA.json" "${TMPDIR}/METADATA.json.bak"
   fi
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
if jq --exit-status . "${TMPDIR}/METADATA.json" >/dev/null 2>&1; then
  #Configure git
   git config --global "credential.helper" store
   git config --global "user.email" "AjamX101@gmail.com"
   git config --global "user.name" "Azathothas"
  #Login
   huggingface-cli login --token "${HF_TOKEN}" --add-to-git-credential
  #Clone
   pushd "$(mktemp -d)" >/dev/null 2>&1 && git clone --filter="blob:none" --no-checkout "https://huggingface.co/datasets/pkgforge/bincache" && cd "./bincache"
    git sparse-checkout set "" && git checkout
    HF_REPO_LOCAL="$(realpath .)" && export HF_REPO_LOCAL="${HF_REPO_LOCAL}"
    git lfs install
    huggingface-cli lfs-enable-largefiles "."
   popd >/dev/null 2>&1
  #Update HF
  echo -e "\n[+] Updating Metadata.json ($(realpath ${TMPDIR}/METADATA.json))\n"
  if jq --exit-status . "${TMPDIR}/METADATA.json.bak" >/dev/null 2>&1; then
     cat "${TMPDIR}/METADATA.json.bak" | jq 'walk(if type == "string" and . == "null" then "" else . end)' > "${TMPDIR}/METADATA.json"
   #Generate Snapshots
   pushd "${HF_REPO_LOCAL}" >/dev/null 2>&1
    if jq --exit-status . "${TMPDIR}/METADATA.json" >/dev/null 2>&1; then
    #BaseUtils
     jq -c '.base[]' "${TMPDIR}/METADATA.json" | while read -r ITEM; do
      NAME="$(echo "${ITEM}" | jq -r '.download_url | split("/") | .[-2] + "/" + .[-1]')"
      SNAPSHOTS="$(git --no-pager log --skip=1 -n 3 "origin/main" --pretty=format:'{"commit":"%H","date":"%cd"}' --date=format:"%Y-%m-%dT%H:%M:%S" -- "${HOST_TRIPLET}/Baseutils/${NAME}" | \
          jq -r --arg host "${HOST_TRIPLET}" --arg name "${NAME}" '"https://huggingface.co/datasets/pkgforge/bincache/resolve/\(.commit)/\($host)/\($name)#[\(.date)]"' | \
          jq -R . | jq -s .)"
      S_JSON="$(echo "${ITEM}" | jq --argjson snapshots "${SNAPSHOTS}" '.snapshots = $snapshots')"
      echo "${S_JSON}" 2>/dev/null
      done > "${TMPDIR}/METADATA.json.base.snaps"
      if jq --exit-status . "${TMPDIR}/METADATA.json.base.snaps" >/dev/null 2>&1; then
         cat "${TMPDIR}/METADATA.json.base.snaps" | jq -s '.' > "${TMPDIR}/METADATA.json.base"
      else
         exit 1
      fi
    #Bin  
     jq -c '.bin[]' "${TMPDIR}/METADATA.json" | while read -r ITEM; do
      NAME="$(echo "${ITEM}" | jq -r '.pkg')"
      SNAPSHOTS="$(git --no-pager log --skip=1 -n 3 "origin/main" --pretty=format:'{"commit":"%H","date":"%cd"}' --date=format:"%Y-%m-%dT%H:%M:%S" -- "${HOST_TRIPLET}/${NAME}" | \
          jq -r --arg host "${HOST_TRIPLET}" --arg name "${NAME}" '"https://huggingface.co/datasets/pkgforge/bincache/resolve/\(.commit)/\($host)/\($name)#[\(.date)]"' | \
          jq -R . | jq -s .)"
      S_JSON="$(echo "${ITEM}" | jq --argjson snapshots "${SNAPSHOTS}" '.snapshots = $snapshots')"
      echo "${S_JSON}" 2>/dev/null
      done > "${TMPDIR}/METADATA.json.bin.snaps"
      if jq --exit-status . "${TMPDIR}/METADATA.json.bin.snaps" >/dev/null 2>&1; then
         cat "${TMPDIR}/METADATA.json.bin.snaps" | jq -s '.' > "${TMPDIR}/METADATA.json.bin"
      else
         exit 1
      fi
    fi
    #Merge
     jq '.pkg' "${TMPDIR}/METADATA.json" > "${TMPDIR}/METADATA.json.pkg"
     jq -s '{"base": .[0], "bin": .[1], "pkg": .[2]}' "${TMPDIR}/METADATA.json.base" "${TMPDIR}/METADATA.json.bin" "${TMPDIR}/METADATA.json.pkg" > "${TMPDIR}/METADATA.json.snaps"
    #Validate 
     if jq --exit-status . "${TMPDIR}/METADATA.json.snaps" >/dev/null 2>&1; then
        cat "${TMPDIR}/METADATA.json.snaps" > "${TMPDIR}/METADATA.json"
     else
        exit 1
     fi
   #Sync
    if jq --exit-status . "${TMPDIR}/METADATA.json" >/dev/null 2>&1; then
     git sparse-checkout set ""
     git sparse-checkout set --no-cone --sparse-index "${HOST_TRIPLET}/*.bsum" "${HOST_TRIPLET}/*.json" "${HOST_TRIPLET}/*.log" "${HOST_TRIPLET}/*.png" "${HOST_TRIPLET}/*.temp" "${HOST_TRIPLET}/*.toml" "${HOST_TRIPLET}/*.tmp" "${HOST_TRIPLET}/*.txt" "${HOST_TRIPLET}/*.xz" "${HOST_TRIPLET}/*.yaml" "${HOST_TRIPLET}/*.yml" "${HOST_TRIPLET}/*.zstd"
     git checkout ; ls -lah "." "./${HOST_TRIPLET}"
     find "${HF_REPO_LOCAL}" -type f -size -3c -delete
     #rm "./${HOST_TRIPLET}/METADATA.json.tmp" 2>/dev/null
     find "${HF_REPO_LOCAL}/${HOST_TRIPLET}" -type f -iname "*.capnp*" -exec rm "{}" -rf \; 2>/dev/null
     find "${HF_REPO_LOCAL}/${HOST_TRIPLET}" -type f -iname "*.toml*" -exec rm "{}" -rf \; 2>/dev/null
     find "${HF_REPO_LOCAL}/${HOST_TRIPLET}" -type f -iname "*.yaml*" -exec rm "{}" -rf \; 2>/dev/null
     find "${HF_REPO_LOCAL}/${HOST_TRIPLET}" -type f -iname "*.min.json*" -exec rm "{}" -rf \; 2>/dev/null
     cp -fv "${TMPDIR}/METADATA.json" "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json"
     cp -fv "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json" "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.AIO.json"
     cat "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json" | jq -r tostring > "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.min.json"
     cp -fv "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.min.json" "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.AIO.min.json"
     b3sum "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.bsum"
     cp -fv "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.bsum" "{HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.AIO.json.bsum"
     7z a -t7z -mx="9" -mmt="$(($(nproc)+1))" -bsp1 -bt "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.xz" "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json" 2>/dev/null
     cp -fv "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.xz" "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.AIO.json.xz"
     b3sum "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.xz" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.xz.bsum"
     cp -fv "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.xz.bsum" "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.AIO.json.xz.bsum"
     zstd --ultra -22 --force "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json" -o "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.zstd"
     cp -fv "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.zstd" "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.AIO.json.zstd"
     b3sum "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.zstd" | grep -oE '^[a-f0-9]{64}' | tr -d '[:space:]' > "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.zstd.bsum"
     cp -fv "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.json.zstd.bsum" "${HF_REPO_LOCAL}/${HOST_TRIPLET}/METADATA.AIO.json.zstd.bsum"
   #Commit & Push
     git add --all --verbose && git commit -m "[+] METADATA (${HOST_TRIPLET}) [$(TZ='UTC' date +'%Y_%m_%d')]"
     git branch -a || git show-branch
     git fetch origin main ; git push origin main
    fi
   popd >/dev/null 2>&1
  else
     echo -e "\n[-] FATAL: ($(realpath ${TMPDIR}/METADATA.json)) is Inavlid\n"
   exit 1
  fi
fi
#-------------------------------------------------------#
