
void bitclient_generateTxHash(uint32 userExtraNonceLength, uint8* userExtraNonce, uint32 coinBase1Length, uint8* coinBase1, uint32 coinBase2Length, uint8* coinBase2, uint8* txHash, uint32 mode);
void bitclient_calculateMerkleRoot(uint8* txHashes, uint32 numberOfTxHashes, uint8* merkleRoot, uint32 mode);
// misc
void bitclient_addVarIntFromStream(stream_t* msgStream, uint64 varInt);

#define TX_MODE_DOUBLE_SHA256	(0)
#define TX_MODE_SINGLE_SHA256	(1)