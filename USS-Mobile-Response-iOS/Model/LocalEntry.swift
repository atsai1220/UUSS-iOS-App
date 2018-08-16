//
//  LocalEntry.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/15/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

/*
 create_resource()
 Param1    $resource_type       The ID of the resource type for the new resource (e.g. 1=Photo).
 Param2    $archive             The archival state of the new resource (0=live).
 Param3    $url                 Optional; v8.1 and above
                                The URL of a file to upload. ResourceSpace will copy the file to the local system then import it to the specified resource.
 Param4    $no_exif             Optional; v8.1 and above
                                Do not process embedded metadata. Leave blank for the default (to process data).
 Param5    $revert              Not currently used, leave blank.
 Param6    $autorotate          Optional; v8.1 and above
                                Automatically rotate (correct) images if the rotation flag is set on the image.
 Param7    $metadata            Optional; v8.1 and above
                                The metadata to add. A JSON encoded array of field ID to value string pairs. See the example in api/example.php.
 
 add_alternative_file()
 Param1    $resource            The ID of the resource.
 Param2    $name                A short descriptive name for the new alternative file.
 Param3    $description         A more verbose description.
 Param4    $file_name           The file name of the new alternative file.
 Param5    $file_extension      The extension of the new alternative file.
 Param6    $file_size           The size of the alternative file in bytes
 Param7    $alt_type
 Param8    $file                Optional; v8.1 and above
                                Alternative file location to copy over to ResourceSpace. Can be a physical path or URL.
 
 add_resource_to_collection()
 Param1    $resource            The ID of the resource.
 Param2    $collection          The ID of the collection to add the resource to.
 */
import Foundation

struct LocalEntry: Codable {
    var name: String?
    var resourceRef: String?
    var collectionRef: String?
    var resourceType: String?
    var archive: String?
    var url: String?
    var localURL: String?
    var no_exif: String?
    var autorotate: String?
    var metadata: metadataJSON?
}

// field ID to value string pairs.
struct metadataJSON: Codable {
    var foo: String?
}
