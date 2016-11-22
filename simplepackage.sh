#!/bin/bash
#this script creates a simple archival information package in which the data objects are placed into a directory called video files and the metadata files are placed into a directory called metadata, and both of these directories are stored in a directory based on the file name of the input file. 


while [ "${*}" != "" ] ; do
    INPUT="${1}"
    MEDIAID=$(basename "${INPUT}" | cut -d. -f1)
    shift
    
    #set up the directory structure of the package on the computer's desktop
	PACKAGE="$HOME/Desktop/${MEDIAID}/"
    mkdir -p "${PACKAGE}"
	METADATAFILES="${PACKAGE}/metadata/"
    mkdir -p "${METADATAFILES}"
	VIDEOFILES="${PACKAGE}/videofiles/"
    mkdir -p "${VIDEOFILES}"
    
	#encode an access copy with the file name as the media id and add an _access
    OUTPUT="${MEDIAID}_access.mov"
	ffmpeg -i "${INPUT}" -c:v libx264 -pix_fmt yuv420p -preset veryslow -crf 18 -c:a copy "${OUTPUT}"
	
	#create mediainfo.xml file with technical metadata in metadata directory
	#if you have this data in a structured format, it is easier to manipulate
	MEDIAINFOXML1="${METADATAFILES}/${MEDIAID}_mediainfo.xml"
    mediaconch -mi -fx "${INPUT}" | xml fo > "${MEDIAINFOXML1}"
	MEDIAINFOXML2="${METADATAFILES}/${OUTPUT}_mediainfo.xml"
    mediaconch -mi -fx "${OUTPUT}" | xml fo > "${MEDIAINFOXML2}"
	
	#move the preservation master and access copy into the videofiles directory 
	mv -v -n "${INPUT}" "${VIDEOFILES}"
    mv -v -n "${OUTPUT}" "${VIDEOFILES}"
	
	#create checksums for files in the videofiles directory 
	cd "${VIDEOFILES}"
	echo "Creating checksums for the video files..."
	md5deep -drl . > "${METADATAFILES}/checksum.md5"
    cd 
	
	#report that the script has completed processing media id 
	echo "The processing of package ${MEDIAID} is complete."

done