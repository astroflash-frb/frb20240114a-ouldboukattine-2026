#!/bin/bash
#
# THIS IS EXTREMELY SPECIFIC - nobody is going to use this
#
# fix_names.sh
#
# Batch-renames VDIF-related data files by inserting "-2" after the session
# identifier and updates corresponding .hdr files so that their DATAFILE
# entries point to the renamed files in the correct directory.
#
# Example rename:
#   p47021_wb_no0013_IF1.vdif
#   -> p47021-2_wb_no0013_IF1.vdif
#
# Example HDR update:
#   DATAFILE   /scratch0/omar/p47021-2/p47021-2_wb_no0013_IF1.vdif
#
# Assumed filename pattern:
#   <session>_<backend>_no<NNNN>[_IFX].vdif
#   <session>_<backend>_no<NNNN>[_IFX].vdif_polX.hdr
#
# Where <session> may be:
#   p47024
#   rn1l11
#   or any other alphanumeric string.
#
# The script:
#   1) Renames all files matching "*_*_no*" by inserting "-2" after <session>
#   2) Updates DATAFILE lines in all *.hdr files accordingly
#
# Safety:
#   - Files already containing "-2" in the session name are skipped
#   - Overwrites DATAFILE lines unconditionally
#
# Usage:
#   chmod +x fix_names.sh
#   ./fix_names.sh
#
# Optional:
#   Perform a dry run by replacing "mv -v" with "echo mv"
#

echo "Renaming data files..."
for f in *_*_no*; do
  session="${f%%_*}"
  rest="${f#${session}}"
  [[ "$session" == *"-2" ]] && continue
  mv -v "$f" "${session}-2${rest}"
done

echo "Fixing HDR DATAFILE paths..."
for f in *.hdr; do
  session="${f%%_*}"              # e.g., p47021-2
  base="${f%.hdr}"                # remove .hdr
  # Remove _polX if exists
  base="${base%%_pol*}"           
  # Remove any trailing .vdif
  base="${base%.vdif}"            
  # Make sure we stop before the last _IFX or number
  # This keeps everything up to IF7 intact
  sed -i "s|^DATAFILE .*|DATAFILE   /scratch0/omar/${session}/${base}.vdif|" "$f"
done
