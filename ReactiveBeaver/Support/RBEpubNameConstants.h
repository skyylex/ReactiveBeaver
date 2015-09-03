//
//  RBEpubNameConstants.h
//  ReactiveBeaver
//
//  Created by skyylex on 06/06/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#ifndef RBParser_RBubNameConstants_h
#define RBParser_RBubNameConstants_h

static NSString *const RBEpubMetaInfFolder = @"META-INF";
static NSString *const RBEpubOEBPSFolder = @"OEBPS";
static NSString *const RBEpubMimetypeFolder = @"mimetype";

/// container.xml
static NSString *const RBEpubContainerXMLName = @"container.xml";
static NSString *const RBEpubContainerXMLRootNodeName = @"container";
static NSString *const RBEpubContainerXMLParentNodeName = @"rootfiles";
static NSString *const RBEpubContainerXMLTargetNodeName = @"rootfile";

static NSString *const RBEpubContainerXMLFullPathAttribute = @"full-path";

/// content.opf
static NSString *const RBEpubContentOPFMetadataElement = @"metadata";
static NSString *const RBEpubContentOPFSpineElement = @"spine";
static NSString *const RBEpubContentOPFManifestElement = @"manifest";

#endif
