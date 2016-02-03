//TODO: document everything
module shapelib; ///
import core.stdc.stdio; //#include <stdio.h>

nothrow:
@nogc:

alias SAFile = int*; ///
alias SAOffset = core.stdc.config.c_ulong; ///
///
struct SAHooks
{
    extern (C) SAFile function(const(char)* filename, const(char)* access) FOpen; ///
    extern (C) SAOffset function(void* p, SAOffset size, SAOffset nmemb, SAFile file) FRead; ///
    extern (C) SAOffset function(void* p, SAOffset size, SAOffset nmemb, SAFile file) FWrite; ///
    extern (C) SAOffset function(SAFile file, SAOffset offset, int whence) FSeek; ///
    extern (C) SAOffset function(SAFile file) FTell; ///
    extern (C) int function(SAFile file) FFlush; ///
    extern (C) int function(SAFile file) FClose; ///
    extern (C) int function(SAFile file) Remove; ///
    pragma(mangle, "Error") extern (C) void function(SAFile file) Error_; ///
    extern (C) double function(SAFile file) Atof; ///
}

extern (C) void SASetupDefaultHooks(SAHooks* psHooks); ///
extern (C) void SASetupUtf8Hooks(SAHooks* psHooks); ///
///
struct SHPInfo
{
    SAHooks sHooks; ///
    SAFile fpSHP; ///
    SAFile fpSHX; ///
    int nShapeType; ///
    uint nFileSize; ///
    int nRecords; ///
    int nMaxRecords; ///
    uint* panRecOffset; ///
    uint* panRecSize; ///
    double[4] adBoundsMin; ///
    double[4] adBoundsMax; ///
    int bUpdated; ///
    ubyte pabyRec; ///
    int nBufSize; ///
}

alias SHPHandle = SHPInfo*; ///
///
enum 
{
    SHPT_NULL = 0, ///
    SHPT_POINT = 1, ///
    SHPT_ARC = 3, ///
    SHPT_POLYGON = 5, ///
    SHPT_MULTIPOINT = 8, ///
    SHPT_POINTZ = 11, ///
    SHPT_ARCZ = 13, ///
    SHPT_POLYGONZ = 15, ///
    SHPT_MULTIPOINTZ = 18, ///
    SHPT_POINTM = 21, ///
    SHPT_ARCM = 23, ///
    SHPT_POLYGONM = 25, ///
    SHPT_MULTIPOINTM = 28, ///
    SHPT_MULTIPATCH = 31 ///
}
///
enum 
{
    SHPP_TRISTRIP = 0, ///
    SHPP_TRIFAN = 1, ///
    SHPP_OUTERRING = 2, ///
    SHPP_INNERRING = 3, ///
    SHPP_FIRSTRING = 4, ///
    SHPP_RING = 5, ///
}
///
struct SHPObject
{
    int nSHPType; ///
    int nShapeId; ///
    int nParts; ///
    int* panPartStart; ///
    int* panPartType; ///
    int nVertices; ///
    double* padfX; ///
    double* padfY; ///
    double* padfZ; ///
    double* padfM; ///
    double dfXMin; ///
    double dfYMin; ///
    double dfZMin; ///
    double dfMMin; ///
    double dfXMax; ///
    double dfYMax; ///
    double dfZMax; ///
    double dfMMax; ///
    int bMeasureIsUsed; ///
}

extern (C) SHPHandle SHPOpen(const(char)* filename, const(char)* pszAcces); ///
extern (C) SHPHandle SHPOpenLL(const(char)* pszShapeFile, const(char)* pszAccess, SAHooks* psHooks); ///
extern (C) SHPHandle SHPCreate(const(char)* pszShapeFile, int nShapeType); ///
extern (C) SHPHandle SHPCreateLL(const(char)* pszShapeFile, int nShapeType, SAHooks* psHooks); ///
extern (C) void SHPGetInfo(SHPHandle hSHP, int* pnEntities, int* pnShapeType,
    double* padfMinBound, double* padfMaxBound); ///
extern (C) SHPObject* SHPReadObject(SHPHandle hSHP, int iShape); ///
extern (C) int SHPWriteObject(SHPHandle hSHP, int iShape, SHPObject* psObject); ///
extern (C) void SHPDestroyObject(SHPObject* psObject); ///
extern (C) void SHPComputeExtents(SHPObject* psObject); ///
extern (C) SHPObject* SHPCreateObject(int nSHPType, int nShapeId, int nParts,
    const(int)* panPartStart, const(int)* panPartType, int nVertices,
    const(double)* padfX, const(double)* padfY, const(double)* padfZ, const(double)* padfM); ///
extern (C) SHPObject* SHPCreateSimpleObject(int nSHPType, int nVertices,
    const(double)* padfX, const(double)* padfY, const(double)* padfZ); ///
extern (C) int SHPRewindObject(SHPHandle hSHP, SHPObject* psObject); ///
extern (C) void SHPClose(SHPHandle hSHP); ///
extern (C) void SHPWriteHeader(SHPHandle hSHP); ///
extern (C) const(char)* SHPTypeName(int nSHPType); ///
extern (C) const(char)* SHPPartTypeName(int nPartType); ///
enum MAX_SUBNODE = 4; ///
enum MAX_DEFAULT_TREE_DEPTH = 12; ///
///
struct SHPTreeNode
{
    double[4] adBoundsMin; ///
    double[4] adBoundsMax; ///
    int nShapeCount; ///
    int* panShapeIds; ///
    SHPObject** papsShapeObj; ///
    int nSubNodes; ///
    SHPTreeNode[MAX_SUBNODE]* apsSubNode; ///
}
///
struct SHPTree
{
    SHPHandle hSHP; ///
    int nMaxDepth; ///
    int nDimension; ///
    int nTotalCount; ///
    SHPTreeNode* psRoot; ///
}

extern (C) SHPTree* SHPCreateTree(SHPHandle hSHP, int nDimension, int nMaxDepth,
    double* padfBoundsMin, double* padfBoundsMax); ///
extern (C) void SHPDestroyTree(SHPTree* hTree); ///
extern (C) int SHPWriteTree(SHPTree* hTree, const(char)* pszFilename); ///
extern (C) int SHPTreeAddShapeId(SHPTree* hTree, SHPObject* psObject); ///
extern (C) int SHPTreeRemoveShapeId(SHPTree* hTree, int nShapeId); ///
extern (C) void SHPTreeTrimExtraNodes(SHPTree* hTree); ///
extern (C) int* SHPTreeFindLikelyShapes(SHPTree* hTree, double* padfBoundsMin,
    double* padfBoundsMax, int* pnShapeCount); ///
extern (C) int SHPCheckBoundsOverlap(double* padfBox1Min, double* padfBox1Max,
    double* padfBox2Min, double* padfBox2Max, int nDimension); ///
extern (C) int* SHPSearchDiskTree(FILE* fp, double* padfBoundsMin,
    double* padfBoundsMax, int* pnShapeCount); ///
///
struct SHPDiskTreeInfo
{
    SAHooks sHooks; ///
    SAFile fpQIX; ///
}

alias SHPTreeDiskHandle = SHPDiskTreeInfo*; ///
extern (C) SHPTreeDiskHandle SHPOpenDiskTree(const(char)* pszQIXFilename, SAHooks* psHooks); ///
extern (C) void SHPCloseDiskTree(SHPTreeDiskHandle hDiskTree); ///
extern (C) int* SHPSearchDiskTreeEx(SHPTreeDiskHandle hDiskTree,
    double* padfBoundsMin, double* padfBoundsMax, int* pnShapeCount); ///
extern (C) int SHPWriteTreeLL(SHPTree* hTree, const char* pszFilename, SAHooks* psHooks); ///
///
struct DBFInfo
{
    SAHooks sHooks; ///
    SAFile fp; ///
    int nRecords; ///
    int nRecordLength; ///
    int nHeaderLength; ///
    int nFields; ///
    int* panFieldOffset; ///
    int* panFieldSize; ///
    int* panFieldDecimals; ///
    char* pachFieldType; ///
    char* pszHeader; ///
    int nCurrentRecord; ///
    int bCurrentRecordModified; ///
    char* pszCurrentRecord; ///
    int nWorkFieldLength; ///
    char* pszWorkField; ///
    int bNoHeader; ///
    int bUpdated; ///
    double dfDoubleField; ///
    int iLanguageDriver; ///
    char* pszCodePage; ///
}

alias DBFHandle = DBFInfo*; ///
///
enum DBFFieldType
{
    FTString, ///
    FTInteger, ///
    FTDouble, ///
    FTLogical, ///
    FTInvalid ///
}

enum int XBASE_FLDHDR_SZ = 32; ///
extern (C) DBFHandle DBFOpen(const(char)* pszDBFFile, const(char)* pszAccess); ///
extern (C) DBFHandle DBFOpenLL(const(char)* pszDBFFile, const(char)* pszAccess, SAHooks* psHooks); ///
extern (C) DBFHandle DBFCreate(const(char)* pszDBFFile); ///
extern (C) DBFHandle DBFCreateEx(const(char)* pszDBFFile, const(char)* pszCodePage); ///
extern (C) DBFHandle DBFCreateLL(const(char)* pszDBFFile,
    const(char)* pszCodePage, SAHooks* psHooks); ///
extern (C) int DBFGetFieldCount(DBFHandle psDBF); ///
extern (C) int DBFGetRecordCount(DBFHandle psDBF); ///
extern (C) int DBFAddField(DBFHandle hDBF, const(char)* pszFieldName,
    DBFFieldType eType, int nWidth, int nDecimals); ///
extern (C) int DBFAddNativeFieldType(DBFHandle hDBF, const(char)* pszFieldName,
    char chType, int nWidth, int nDecimals); ///
extern (C) int DBFDeleteField(DBFHandle hDBF, int iField); ///
extern (C) int DBFReorderFields(DBFHandle psDBF, int* panMap); ///
extern (C) int DBFAlterFieldDefn(DBFHandle psDBF, int iField,
    const(char)* pszFieldName, char chType, int nWidth, int nDecimals); ///
extern (C) DBFFieldType DBFGetFieldInfo(DBFHandle psDBF, int iField,
    char* pszFieldName, int* pnWidth, int* pnDecimals); ///
extern (C) int DBFGetFieldIndex(DBFHandle psDBF, const(char)* pszFieldName); ///
extern (C) int DBFReadIntegerAttribute(DBFHandle hDBF, int iShape, int iField); ///
extern (C) double DBFReadDoubleAttribute(DBFHandle hDBF, int iShape, int iField); ///
extern (C) const(char)* DBFReadStringAttribute(DBFHandle hDBF, int iShape, int iField); ///
extern (C) const(char)* DBFReadLogicalAttribute(DBFHandle hDBF, int iShape, int iField); ///
extern (C) int DBFIsAttributeNULL(DBFHandle hDBF, int iShape, int iField); ///
extern (C) int DBFWriteIntegerAttribute(DBFHandle hDBF, int iShape, int iField, int nFieldValue); ///
extern (C) int DBFWriteDoubleAttribute(DBFHandle hDBF, int iShape, int iField, double dFieldValue); ///
extern (C) int DBFWriteStringAttribute(DBFHandle hDBF, int iShape, int iField,
    const(char)* pszFieldValue); ///
extern (C) int DBFWriteNULLAttribute(DBFHandle hDBF, int iShape, int iField); ///
extern (C) int DBFWriteLogicalAttribute(DBFHandle hDBF, int iShape, int iField,
    const(char) lFieldValue); ///
extern (C) int DBFWriteAttributeDirectly(DBFHandle psDBF, int hEntity, int iField,
    void* pValue); ///
extern (C) const(char)* DBFReadTuple(DBFHandle psDBF, int hEntity); ///
extern (C) int DBFWriteTuple(DBFHandle psDBF, int hEntity, void* pRawTuple); ///
extern (C) int DBFIsRecordDeleted(DBFHandle psDBF, int iShape); ///
extern (C) int DBFMarkRecordDeleted(DBFHandle psDBF, int iShape, int bIsDeleted); ///
extern (C) DBFHandle DBFCloneEmpty(DBFHandle psDBF, const(char)* pszFilename); ///
extern (C) void DBFClose(DBFHandle hDBF); ///
extern (C) void DBFUpdateHeader(DBFHandle hDBF); ///
extern (C) char DBFGetNativeFieldType(DBFHandle hDBF, int iField); ///
extern (C) const(char)* DBFGetCodePage(DBFHandle psDBF); ///
