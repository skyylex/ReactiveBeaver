//
//  SKEpubNameConstants.h
//  SKEPParser
//
//  Created by skyylex on 06/06/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#ifndef SKEPParser_SKEpubNameConstants_h
#define SKEPParser_SKEpubNameConstants_h

static NSString *const SKEPEpubMetaInfFolder = @"META-INF";
static NSString *const SKEPEpubOEBPSFolder = @"OEBPS";
static NSString *const SKEPEpubMimetypeFolder = @"mimetype";

/// container.xml
static NSString *const SKEPEpubContainerXMLName = @"container.xml";
static NSString *const SKEPEpubContainerXMLRootNodeName = @"container";
static NSString *const SKEPEpubContainerXMLParentNodeName = @"rootfiles";
static NSString *const SKEPEpubContainerXMLTargetNodeName = @"rootfile";

static NSString *const SKEPEpubContainerXMLFullPathAttribute = @"full-path";

/// content.opf
static NSString *const SKEPEpubContentOPFSpineElement = @"spine";
static NSString *const SKEPEpubContentOPFManifestElement = @"manifest";

#endif
