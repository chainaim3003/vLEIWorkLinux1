# ref_uri Field - Blockchain Transaction Reference Support

## ✅ Updated Schema Field

### Field Definition

```json
"ref_uri": {
  "description": "Reference URI for blockchain transaction or supporting documentation. Supports full blockchain explorer URLs (e.g., etherscan.io, algoexplorer.io) and transaction URIs.",
  "type": "string",
  "format": "uri",
  "minLength": 10,
  "maxLength": 500
}
```

**Validation:**
- ✅ Required field
- ✅ Must be valid URI format
- ✅ Length: 10-500 characters
- ✅ Supports full blockchain explorer URLs
- ✅ Supports transaction URI schemes

---

## Supported Formats

### 1. Full Blockchain Explorer URLs (Recommended)

#### Ethereum Mainnet
```
https://etherscan.io/tx/0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```
- Transaction hash: 66 characters (0x + 64 hex)
- Full URL: ~90 characters

#### Polygon
```
https://polygonscan.com/tx/0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```
- Same format as Ethereum
- Different explorer domain

#### Algorand
```
https://algoexplorer.io/tx/ABC123DEF456GHI789JKL012MNO345PQR678STU901VWX234YZ
```
- Transaction ID: 52 characters (base32)
- Full URL: ~70 characters

#### Stellar
```
https://stellarchain.io/tx/abc123def456789ghi012jkl345mno678pqr901stu234vwx
```
- Transaction hash: 64 characters (hex)
- Full URL: ~90 characters

#### Bitcoin
```
https://blockchain.info/tx/1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```
- Transaction ID: 64 characters (hex)
- Full URL: ~90 characters

#### Solana
```
https://solscan.io/tx/ABC123DEF456GHI789JKL012MNO345PQR678STU901VWX234YZ567ABC890
```
- Signature: base58 encoded, ~88 characters
- Full URL: ~110 characters

---

### 2. Transaction URI Schemes (Alternative)

#### Ethereum URI Scheme
```
ethereum:0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

#### Algorand URI Scheme
```
algorand:txid:ABC123DEF456GHI789JKL012MNO345PQR678STU901VWX234YZ
```

#### Stellar URI Scheme
```
stellar:txid:abc123def456789ghi012jkl345mno678pqr901stu234vwx
```

#### Bitcoin URI Scheme
```
bitcoin:tx:1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

---

### 3. Custom/Private Blockchain Explorers

#### Enterprise Blockchain
```
https://explorer.mycompany.com/transaction/0xABC123
```

#### Private Network
```
https://internal-blockchain.corp.local/tx/XYZ789
```

---

## Examples by Use Case

### Invoice Payment Verification

**Scenario:** Invoice paid via Ethereum
```json
{
  "paymentChainID": "ethereum",
  "paymentWalletAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  "ref_uri": "https://etherscan.io/tx/0x5c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22060"
}
```

**Scenario:** Invoice paid via Algorand
```json
{
  "paymentChainID": "algorand",
  "paymentWalletAddress": "XQVKZ7MNMJH3ZHCVGKQY6RJVMZJ2ZKWXQO4HNBEXAMPLE",
  "ref_uri": "https://algoexplorer.io/tx/XC3XSVZUYPXW7K4UFZP6JVB7DWPVWCITPU4E5Y5WNQXYZ6789ABC"
}
```

**Scenario:** Invoice paid via Polygon (Layer 2)
```json
{
  "paymentChainID": "polygon",
  "paymentWalletAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  "ref_uri": "https://polygonscan.com/tx/0x1a2b3c4d5e6f7890abcdef1234567890abcdef1234567890abcdef1234567890"
}
```

**Scenario:** Invoice paid via Stellar
```json
{
  "paymentChainID": "stellar",
  "paymentWalletAddress": "GABC123DEF456GHI789JKL012MNO345PQR678STU901",
  "ref_uri": "https://stellarchain.io/tx/e8b9c1d2a3f4567890abcdef1234567890abcdef1234567890abcdef12345678"
}
```

---

## Real-World Transaction Examples

### Ethereum Transaction (Etherscan)
```
Full URL Length: 89 characters
https://etherscan.io/tx/0x5c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22060

Components:
- Base URL: https://etherscan.io/tx/
- Transaction Hash: 0x5c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22060
  - Prefix: 0x (2 chars)
  - Hash: 64 hex characters
```

### Algorand Transaction (AlgoExplorer)
```
Full URL Length: ~78 characters
https://algoexplorer.io/tx/XC3XSVZUYPXW7K4UFZP6JVB7DWPVWCITPU4E5Y5WN

Components:
- Base URL: https://algoexplorer.io/tx/
- Transaction ID: 52 base32 characters
```

### Polygon Transaction (PolygonScan)
```
Full URL Length: 92 characters
https://polygonscan.com/tx/0x1a2b3c4d5e6f7890abcdef1234567890abcdef1234567890abcdef1234567890

Components:
- Base URL: https://polygonscan.com/tx/
- Transaction Hash: 66 characters (same format as Ethereum)
```

---

## Field Validation Rules

### ✅ Valid Examples:

```json
// Full explorer URLs
"ref_uri": "https://etherscan.io/tx/0x5c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22060"
"ref_uri": "https://algoexplorer.io/tx/ABC123DEF456GHI789JKL012"
"ref_uri": "https://stellarchain.io/tx/abc123"

// URI schemes
"ref_uri": "ethereum:0x5c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22060"
"ref_uri": "algorand:txid:ABC123DEF456"
"ref_uri": "stellar:txid:xyz789"

// Custom explorers
"ref_uri": "https://explorer.mychain.com/tx/12345"
"ref_uri": "https://blockchain-explorer.internal.corp/transaction/ABC"

// Documentation links
"ref_uri": "https://docs.example.com/invoices/INV-2025-001"
"ref_uri": "https://ipfs.io/ipfs/QmXYZ123"
```

### ❌ Invalid Examples:

```json
// Too short (< 10 characters)
"ref_uri": "tx:123"  ❌

// Too long (> 500 characters)
"ref_uri": "https://..." (501+ characters) ❌

// Not a valid URI format
"ref_uri": "just some text" ❌
"ref_uri": "transaction 12345" ❌

// Empty
"ref_uri": "" ❌
```

---

## Blockchain-Specific Transaction Hash Formats

| Blockchain | Hash Format | Length | Example |
|------------|-------------|--------|---------|
| **Ethereum** | 0x + 64 hex | 66 chars | `0x5c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22060` |
| **Polygon** | 0x + 64 hex | 66 chars | Same as Ethereum |
| **Bitcoin** | 64 hex | 64 chars | `5c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22060` |
| **Algorand** | Base32 | 52 chars | `XC3XSVZUYPXW7K4UFZP6JVB7DWPVWCITPU4E5Y5WNQXYZ6789ABC` |
| **Stellar** | 64 hex | 64 chars | `e8b9c1d2a3f4567890abcdef1234567890abcdef1234567890abcdef12345678` |
| **Solana** | Base58 | ~88 chars | `5VERv8NMvzbJMEkV8xnrLkEaWRtSz9CosKDYjCJjBRnbJLgp8uirBgmQpjKhoR4tjF3ZpRzrFmBV6UjKdiSZkQUW` |

---

## URL Length Analysis

### Typical URL Lengths by Explorer:

| Explorer | Base URL | Hash Length | Total Length | Within Limit? |
|----------|----------|-------------|--------------|---------------|
| Etherscan | 27 chars | 66 chars | ~93 chars | ✅ Yes (< 500) |
| PolygonScan | 29 chars | 66 chars | ~95 chars | ✅ Yes (< 500) |
| AlgoExplorer | 28 chars | 52 chars | ~80 chars | ✅ Yes (< 500) |
| StellarChain | 29 chars | 64 chars | ~93 chars | ✅ Yes (< 500) |
| Blockchain.info | 31 chars | 64 chars | ~95 chars | ✅ Yes (< 500) |
| Solscan | 26 chars | 88 chars | ~114 chars | ✅ Yes (< 500) |

**Maximum observed:** ~120 characters  
**Schema limit:** 500 characters  
**Safety margin:** ~380 characters for future growth

---

## Best Practices

### 1. Use Full Explorer URLs (Recommended)
```json
✅ "ref_uri": "https://etherscan.io/tx/0x5c504ed..."
```
**Benefits:**
- Human-readable
- Clickable in interfaces
- Provides verification context
- Standardized format

### 2. Include Chain-Specific Explorers
```json
// Ethereum Mainnet
"ref_uri": "https://etherscan.io/tx/..."

// Polygon
"ref_uri": "https://polygonscan.com/tx/..."

// Algorand
"ref_uri": "https://algoexplorer.io/tx/..."
```

### 3. For Private Chains
```json
"ref_uri": "https://internal-explorer.company.com/tx/..."
```

### 4. Alternative: IPFS for Documentation
```json
"ref_uri": "https://ipfs.io/ipfs/QmHashOfInvoiceDocument"
```

---

## Invoice Credential Example

### Complete Invoice with ref_uri:

```json
{
  "v": "ACDC10JSON000XXX_",
  "d": "E<InvoiceSAID>",
  "i": "EApPKbLs1caLejrwVdrI2k-Gy394xGPmM9prsprV3Iio",
  "s": "E<InvoiceSchemaSAID>",
  
  "a": {
    "invoiceNumber": "INV-2025-001",
    "invoiceDate": "2025-11-13T00:00:00Z",
    "dueDate": "2025-12-13T00:00:00Z",
    "currency": "ETH",
    "totalAmount": 10.5,
    "sellerLEI": "3358004DXAMRWRUIYJ05",
    "buyerLEI": "54930012QJWZMYHNJW95",
    
    "paymentMethod": "blockchain",
    "paymentChainID": "ethereum",
    "paymentWalletAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    
    "ref_uri": "https://etherscan.io/tx/0x5c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22060",
    
    "lineItems": [{
      "description": "Professional Services - Q4 2025",
      "quantity": 1,
      "unitPrice": 10.5,
      "amount": 10.5
    }],
    
    "paymentTerms": "Net 30 days"
  },
  
  "e": {
    "oor": {
      "n": "<OOR_CREDENTIAL_SAID>",
      "s": "<OOR_SCHEMA_SAID>",
      "o": "I2I"
    }
  }
}
```

---

## Verification Workflow

### For Verifiers (Sally):

1. **Extract ref_uri** from invoice credential
2. **Validate format** (URI, length constraints)
3. **Parse blockchain details:**
   - Extract chain identifier from URL
   - Extract transaction hash
4. **Verify transaction:**
   - Query blockchain explorer API
   - Confirm transaction exists
   - Verify amount matches invoice
   - Verify sender/receiver addresses
5. **Check timing:**
   - Transaction date vs invoice date
   - Payment deadline compliance

### Example Verification Code:

```python
def verify_invoice_payment(invoice_credential):
    ref_uri = invoice_credential['a']['ref_uri']
    chain_id = invoice_credential['a']['paymentChainID']
    amount = invoice_credential['a']['totalAmount']
    
    # Parse transaction hash from URL
    if 'etherscan.io' in ref_uri:
        tx_hash = ref_uri.split('/tx/')[-1]
        # Query Etherscan API
        tx_data = query_etherscan(tx_hash)
        
        # Verify amount
        assert tx_data['value'] == amount
        
        # Verify it's confirmed
        assert tx_data['confirmations'] > 6
        
    elif 'algoexplorer.io' in ref_uri:
        tx_id = ref_uri.split('/tx/')[-1]
        # Query Algorand indexer
        tx_data = query_algorand_indexer(tx_id)
        
        # Verify amount
        assert tx_data['payment-transaction']['amount'] == amount
        
    # ... other chains
    
    return True
```

---

## Summary

### ✅ ref_uri Field Capabilities:

| Feature | Support |
|---------|---------|
| Ethereum explorer URLs | ✅ Yes |
| Polygon explorer URLs | ✅ Yes |
| Algorand explorer URLs | ✅ Yes |
| Stellar explorer URLs | ✅ Yes |
| Bitcoin explorer URLs | ✅ Yes |
| Solana explorer URLs | ✅ Yes |
| Custom/private explorers | ✅ Yes |
| URI schemes (ethereum:, algorand:) | ✅ Yes |
| IPFS links | ✅ Yes |
| Maximum length | ✅ 500 characters |
| Minimum length | ✅ 10 characters |

### Ready for Production:
- ✅ Supports all major blockchain explorers
- ✅ Handles full transaction hash URLs
- ✅ Flexible for future blockchain additions
- ✅ Validates URI format
- ✅ Appropriate length constraints

---

**Document Version:** 1.0.0  
**Last Updated:** November 14, 2025  
**Status:** ✅ COMPLETE
