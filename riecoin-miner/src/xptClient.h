#define XPT_DEVELOPER_FEE_MAX_ENTRIES	(8)

typedef struct  
{
	uint8 algorithm;
	uint8 merkleRoot[32];
	uint8 prevBlockHash[32];
	uint32 version;
	uint32 nonce;
	uint32 nTime;
	uint32 nBits;
	// primecoin specific
	uint32 sieveSize;
	uint32 sieveCandidate; // index of sieveCandidate for this share
	uint8 fixedMultiplierSize;
	uint8 fixedMultiplier[201];
	uint8 chainMultiplierSize;
	uint8 chainMultiplier[201];
	// protoshare specific
	uint32 nBirthdayA;
	uint32 nBirthdayB;
	// riecoin specific
	uint8  riecoin_nOffset[32];
	// gbt stuff
	uint8 merkleRootOriginal[32];
	uint32 userExtraNonceLength;
	uint8 userExtraNonceData[16];
}xptShareToSubmit_t;

typedef struct  
{
	uint16 devFee;
	uint8  pubKeyHash[20]; // RIPEMD160 hash of public key (retrieved from wallet address without prefix byte and without checksum)
}xptDevFeeEntry_t;

typedef struct  
{
	SOCKET clientSocket;
	xptPacketbuffer_t* sendBuffer; // buffer for sending data
	xptPacketbuffer_t* recvBuffer; // buffer for receiving data
	// worker info
	char username[128];
	char password[128];
	uint32 clientState;
	uint8 algorithm; // see ALGORITHM_* constants
	// recv info
	uint32 recvSize;
	uint32 recvIndex;
	uint32 opcode;
	// disconnect info
	bool disconnected;
	// work data
	CRITICAL_SECTION cs_workAccess;
	xptBlockWorkInfo_t blockWorkInfo;
	bool hasWorkData;
	float earnedShareValue; // this value is sent by the server with each new block that is sent
	// shares to submit
	CRITICAL_SECTION cs_shareSubmit;
	simpleList_t* list_shareSubmitQueue;
	// timers
	uint32 time_sendPing;
	uint64 pingSum;
	uint32 pingCount;
	// developer fee
	xptDevFeeEntry_t developerFeeEntry[XPT_DEVELOPER_FEE_MAX_ENTRIES];
	sint32 developerFeeCount; // number of developer fee entries
}xptClient_t;

// connection setup
xptClient_t* xptClient_create();
bool xptClient_connect(xptClient_t* xptClient, generalRequestTarget_t* target);
void xptClient_addDeveloperFeeEntry(xptClient_t* xptClient, char* walletAddress, uint16 integerFee, bool isMaxCoinAddress);
void xptClient_free(xptClient_t* xptClient);
void xptClient_forceDisconnect(xptClient_t* xptClient);

// connection processing
bool xptClient_process(xptClient_t* xptClient); // needs to be called in a loop
bool xptClient_isDisconnected(xptClient_t* xptClient, char** reason);
bool xptClient_isAuthenticated(xptClient_t* xptClient);
void xptClient_foundShare(xptClient_t* xptClient, xptShareToSubmit_t* xptShareToSubmit);

// never send this directly
void xptClient_sendWorkerLogin(xptClient_t* xptClient);

// packet handlers
bool xptClient_processPacket_authResponse(xptClient_t* xptClient);
bool xptClient_processPacket_blockData1(xptClient_t* xptClient);
bool xptClient_processPacket_shareAck(xptClient_t* xptClient);
bool xptClient_processPacket_message(xptClient_t* xptClient);
bool xptClient_processPacket_ping(xptClient_t* xptClient);

// util
void xptClient_getDifficultyTargetFromCompact(uint32 nCompact, uint32* hashTarget);

// miner version string (needs to be defined somewhere in the project, max 45 characters)
extern char* minerVersionString;