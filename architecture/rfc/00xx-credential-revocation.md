# RFC 00XX Credential Revocation

## Background
GOV.UK One Login is developing a government wallet - GOV.UK One Login digital wallet - to enable users to acquire, view and share digital versions of government-issued credentials. Over the lifetime of the credential their status may change and it is important to communicate these changes to all parties and applications involved. This document will explore the options for the keeping the Verifiable Credential status up to date. Revocation mechanisms are essential part of identity ecosystems and are required to keep the issuer, holder and verifier up to date with the credential status.

## Requirements

GOV.UK One Login or an issuer may want to revoke credential(s) they have issued.

- The revocation may be permanent or temporary depending on the scenario.
- The revocation must support at least 2 statuses Valid, Invalid.
- The revocation mechanism must be secure, privacy preserving and scalable to billions of records.

Some example scenarios are 

- Revoking a driving licence as a result of disqualification.
- Issuance of a full licence to replace a provisional licence.

## Scope

This RFC builds on the [IETF Oauth Status List RFC](https://datatracker.ietf.org/doc/draft-ietf-oauth-status-list/06/) and focuses on the use of status list to provide up to date statuses for the GOV.UK One Login wallet issuer, holder and verifier.

## References to other design documents

## Options

### IETF OAuth Status List

The [IETF OAuth Status List](https://datatracker.ietf.org/doc/draft-ietf-oauth-status-list/06/) aims to provide a mechanism of communicating semantics about the token or its validity as that may change over time. It specifically calls out token formats secured by [Javascript Object Signing and Encryption](https://www.iana.org/assignments/jose/jose.xhtml) (JOSE) or CBOR Object Signing and Encryption (COSE), such as [JWTs](https://datatracker.ietf.org/doc/html/rfc7519), [SD-JWT VCs](https://datatracker.ietf.org/doc/draft-ietf-oauth-sd-jwt-vc/), [CWTs](https://datatracker.ietf.org/doc/html/rfc8392) and [ISO mdoc](https://www.iso.org/obp/ui/en/#iso:std:69084:en) that have application and relevance to GOV.UK One Login.

The OAuth Status List defines a data structure that describes individual statuses of multiple Referenced Tokens. The statuses of the Referenced Tokens are represented by one or multiple bits in the Status List. Each Referenced Token is allocated an index during issuance and the value of the bit(s) at the index in the Status List represents the status of Referenced Token.

- Each status of a Referenced Token MUST be represented with a bit-size of 1,2,4, or 8. Therefore up to 2,4,16, or 256 statuses for a Referenced Token are possible, depending on the bit-size.
- The overall Status List is encoded as a byte array.
- The status of each Referenced Token is identified using the index that maps to one or more specific bits within the byte array.
- The index starts counting at 0 and ends with "size"- 1.
- The bits within an array are counted from least significant bit "0" to the most significant bit ("7").
```mermaid
block-beta
  block:group1
    7 6 5 4 3 2 1 0
  end
```
- All bits of the byte array at a particular index are set to a status value.
- The byte array is compressed using DEFLATE [RFC1951] with the ZLIB [RFC1950] data format. Implementations are RECOMMENDED to use the highest compression level available.

The following is an example of a JSON Object representing a Status List.

```json
{
  "bits": 1 /* REQUIRED. number of bits per Referenced Token */,
  "lst": "eNrbuRgAAhcBXQ" /* REQUIRED. compressed/base64url-encoded string that contains the status values  */
}
```

Below is a JWT representation of the status list above.

```json
{
    "alg": "ES256",
    "kid": "12",
    "typ": "statuslist+jwt"
  }
  .
  {
    "exp": 2291720170,
    "iat": 1686920170,
    "status_list": {
      "bits": 1,
      "lst": "eNrbuRgAAhcBXQ"
    },
    "sub": "https://example.com/statuslists/1",
    "ttl": 43200
  }
```

Following is an example for a decoded header and payload of a Referenced Token. The issuer can include the status claim in a Referenced Token to allow retrieval of the Status List.

```json
{
  "alg": "ES256",
  "kid": "11"
}
.
{
  "status": {
    "status_list": {
      "idx": 0,
      "uri": "https://example.com/statuslists/1"
    }
  }
}
```

#### Status Types

The OAuth Status List also describes the state, mode, condition or stage of each entity represented by each Referenced Token. If the list contains more than one bit per Referenced Token, for example to represent two states VALID and INVALID, then the whole combination must be used to describe one state. A Referenced Token cannot have multiple states in the Status List. The registry in Section [14.5](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-06.html#name-status-types-registry) of the OAuth Status List RFC includes the most common Status Type Values. See some values below.

- 0x00 - "VALID" - The status of the Referenced Token is valid, correct or legal.
- 0x01 - "INVALID" - The status of the Referenced Token is revoked, annulled, taken back, recalled or cancelled.
- 0x02 - "SUSPENDED" - The status of the Referenced Token is temporarily invalid, hanging, debarred from privilege.  This state is reversible.

#### Validation Rules

The processing rules for JWT or CWT precede any evaluation of a Referenced Token's status. This means if "exp" shows that the Token is expired then even a Valid Status will be considered expired.

#### Pros
- Compressed using DEFLATE [RFC1951] with the ZLIB [RFC1950] data format.
- Allows caching of status list with ttl.
- Provides examples of JWT, CWT and mdoc representations.
- SD-JWT references the user of status list as an option for token status updates.
- An issuer is unable to track the holder as verifiers have to process the list to identify the status.

#### Cons
- New Status Type must be registered in the [Status Types Registry](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-06.html#name-status-types-registry).
- At the time of writing the RFC is draft and not a IETF standard.

### W3C Bitstring Status List

In a [Bitstring Status List](https://www.w3.org/TR/vc-bitstring-status-list/) The status information of a verifiable credential issue by the issuer is represented as items in a list. Each issuer manages a list of all verifiable credentials that it has issued. Each verifiable credential is associated with an item in its list. When a single bit specifies a status, such as "revoked" or "suspended", then that status is expected to be true when the bit is set (1) and false when unset (0).

An individual bit represents a status when the bit is set (1) the status is true for the associated credential. When the bit is unset (0) the status is not true for the credential. A simple example below shows a StatusListCredential with bit at index `94567` representing the `revocation` status for credential at URL "https://example.com/credentials/status/3". Similarly bit at index 23452 represents the "suspension" status of the credential at URL "https://example.com/credentials/status/4".

```json
 Example StatusListCredential using simple entries
{
  "@context": [
    "https://www.w3.org/ns/credentials/v2",
    "https://www.w3.org/ns/credentials/examples/v2"
  ],
  "id": "https://example.com/credentials/23894672394",
  "type": ["VerifiableCredential", "EmployeeIdCredential"],
  "issuer": "did:example:12345",
  "validFrom": "2024-04-05T14:27:42Z",
  "credentialStatus": [{
    "id": "https://example.com/credentials/status/3#94567",
    "type": "BitstringStatusListEntry",
    "statusPurpose": "revocation",
    "statusListIndex": "94567",
    "statusListCredential": "https://example.com/credentials/status/3"
  }, {
    "id": "https://example.com/credentials/status/4#23452",
    "type": "BitstringStatusListEntry",
    "statusPurpose": "suspension",
    "statusListIndex": "23452",
    "statusListCredential": "https://example.com/credentials/status/4"
  }],
  "credentialSubject": {
    "id": "did:example:6789",
    "type": "Person",
    "employeeId": "A-123456"
  }
}
```

A slightly complex example is of an issuer committing to a set of messages associated with a credential. This is done by using "statusListIndex" and "statusSize" (in bits). A statusSize of 2 bits means we can have 4 statuses 00,01,10,11. What each of them mean is represented in "statusMessage". See example Below

```json
Example StatusListCredential using more complex entries
{
  "@context": [
    "https://www.w3.org/ns/credentials/v2",
    "https://www.w3.org/ns/credentials/examples/v2"
  ],
  "id": "https://example.com/credentials/2947478373",
  "type": ["VerifiableCredential", "BillOfLadingExampleCredential"],
  "issuer": "did:example:12345",
  "validFrom": "2024-04-05T03:52:31Z",
  "credentialStatus": {
    "id": "https://example.com/credentials/status/8#492847",
    "type": "BitstringStatusListEntry",
    "statusPurpose": "message",
    "statusListIndex": "492847",
    "statusSize": 2,
    "statusListCredential": "https://example.com/credentials/status/8",
    "statusMessage": [
        {"status":"0x0", "message":"pending_review"},
        {"status":"0x1", "message":"accepted"},
        {"status":"0x2", "message":"rejected"},
        ...
    ],
    "statusReference": "https://example.org/status-dictionary/"
  },
  "credentialSubject": {
    "id": "did:example:6789",
    "type": "BillOfLading",
    ...
  }
}
```


```json
Example BitstringStatusListCredential
{
  "@context": [
    "https://www.w3.org/ns/credentials/v2"
  ],
  "id": "https://example.com/credentials/status/3",
  "type": ["VerifiableCredential", "BitstringStatusListCredential"],
  "issuer": "did:example:12345",
  "validFrom": "2021-04-05T14:27:40Z",
  "credentialSubject": {
    "id": "https://example.com/status/3#list",
    "type": "BitstringStatusList",
    "statusPurpose": "revocation",
    "encodedList": "uH4sIAAAAAAAAA3BMQEAAADCoPVPbQwfoAAAAAAAAAAAAAAAAAAAAIC3AYbSVKsAQAAA"
  }
}
```

Pros
- Highly compressible using run-length compression techniques such as GZIP [RFC1952](https://www.rfc-editor.org/rfc/rfc1952).
- The status list is expressed inside a verifiable credential in order to enable a holder to provide it directly to a verifier.
- The standard has considerations to align implementation to OAuth Status List to allow interoperability in code.
- `BitstringStatusListEntry` `statusMessage` property can be used to describe the number of statuses indicated by `statusSize` property

Cons
- Bitstring Status List is a W3C Candidate Draft and is not a standard yet.
- The working group might change the specification, for example `TTL` conflicts with `validUntil` and it might be removed in the future.
- Using different `statusMessage` across issuers can make the implementation complex for a centralised status list.

### Other Options
The Bitstring Status List provides a good [comparison](https://www.w3.org/TR/vc-bitstring-status-list/#data-model) of the different options available for expressing digital credential status. It can be used as reference for further discussion and is out of scope of this document. 

Below is a list of links for some of the RFCs 
- Certificate Revocation Lists (CRL) [RFC5280](https://www.rfc-editor.org/rfc/rfc5280)
- Online Certificate Status Protocol [OCSP RFC2560](https://datatracker.ietf.org/doc/html/rfc2560)
- Token Introspection Token [rfc7662](https://datatracker.ietf.org/doc/html/rfc7662)

## Solution Design

### Design Considerations

The OAuth Status List and Bitstring Status List provide several security ([1](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-06.html#name-security-considerations), [2](https://www.w3.org/TR/vc-bitstring-status-list/#security-considerations)), privacy ([1](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-06.html#name-privacy-considerations), [2](https://www.w3.org/TR/vc-bitstring-status-list/#privacy-considerations)) and [implementation](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-06.html#name-implementation-consideratio) considerations. Some more are listed below.

- The status update checks must not result in tracking of the holder by the Issuer or the Verifier. 
- The solution should align to standard that will be supported by OIDC and mDl standards.

### Proposed Solution
A Status List is required to provide a efficient and performant mechanism to the issuer, holder and the verifier to ensure all parties are aware of the validity of the credentials. The Status List is a performance enhancement that means the wallet app does not have to re-fetch the credential to ensure its validity, instead it can rely on the Status List to provide that information. This means that the must keep the list up to date and reflect any changes as soon as they are available.

Form the options listed in the sections above the OAuth Status List and Bitstring Status List are the two main options being considered for creating a mechanism for credential revocation Status List. Out of the two options OAuth Status list is the preferred option for the following reasons.

- It has consistent way of storing statuses in a list, that is you have to select 1,2,4 or 8 bits and all statuses in the list must use the same number of bits.
- The [Status Types Values](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-06.html#name-status-types) are part of the specification and predefined. Additional statuses must be registered in the [registry](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-06.html#iana-status-types). This ensures all parties use same Valid, Invalid and Suspended bit combination to represent Status Type values and can use application specific statuses to meet any additional requirements. 
- It defines a mechanism, data structures and processing rules for representing the status of tokens secured by JSON Object Signing and Encryption (JOSE) or CBOR Object Signing and Encryption (COSE), such as JWT, SD-JWT VC, CBOR Web Token and ISO mdoc.
- The Reference Token Issuer (credential issuer in this case), Status Issuer and Status Provider roles can be fulfilled by different entities.
- [SD-Jwt](https://www.ietf.org/archive/id/draft-ietf-oauth-sd-jwt-vc-08.html#name-issuer-holder-verifier-mode) mentions use of a Status Provider and reference Status List  to support revocation of Verifiable Credentials.
- The new draft for ISO-compliant driving licence — Part 5: Mobile driving licence (mDL) application suggests use of Status List for revocation.

> **Note**
>
> At the time of the writing both OAuth Status List and Bitstring Status List are drafts and not standards.

#### Bits and Status Type Values
The proposed solution will use OAuth Status List with 2 bits. Initially only two Status Types will be supported.

- 0x00 - "VALID" - The status of the Referenced Token is valid, correct or legal.

- 0x01 - "INVALID" - The status of the Referenced Token is revoked, annulled, taken back, recalled or cancelled.

A Invalid token cannot be reinstated, changed back to Valid. It must stay revoked for its lifetime. Below is a example list of 8 statuses. Future use-cases may include statuses for suspension and credential refresh. These are not part of the initial scope.

```
status[0] = 1
status[1] = 0
status[2] = 0
status[3] = 1
status[4] = 0
status[5] = 1
status[6] = 0
status[7] = 1
```
The byte array will be represented in the following order.

```
byte             0                  1        
bit       7 6 5 4 3 2 1 0    7 6 5 4 3 2 1 0 
         +-+-+-+-+-+-+-+-+  +-+-+-+-+-+-+-+-+
values   |0|1|0|0|0|0|0|1|  |0|1|0|0|0|1|0|0|
         +-+-+-+-+-+-+-+-+  +-+-+-+-+-+-+-+-+
          \ / \ / \ / \ /    \ / \ / \ / \ / 
status     1   0   0   1      1   0   1   0  
index      3   2   1   0      7   6   5   4  
           \___________/      \___________/  
                0x41               0x44      
```
The resulting byte array and compressed/base64url-encoded Status List is below.
```
byte_array = [0x41, 0x44]
encoded:
{
  "bits": 2,
  "lst": "eNpzdAEAAMgAhg"
}
```
Below is an example of the Status List JWT.
```
{
  "alg": "ES256",
  "kid": "12",
  "typ": "statuslist+jwt"
}
.
{
  "exp": 2291720170,
  "iat": 1686920170,
  "status_list": {
    "bits": 2,
    "lst": "eNpzdAEAAMgAhg"
  },
  "sub": "https://example.com/statuslists/1",
  "ttl": 43200
}
```
Below is an example of Referenced Token with a status claim with a status index and a URI for the Status List Token. 
```
{
  "alg": "ES256",
  "kid": "11"
}
.
{
  "status": {
    "status_list": {
      "idx": 3,
      "uri": "https://example.com/statuslists/1"
    }
  }
}
```
#### Status List Formats
The OAuth Status List RFC defines two token formats for the Status List.
- Json Web Token (JWT)
- CBOR Web Token (CWT)

Both formats will be supported for the implementation.

#### Decentralised Vs Centralised Status List
The status list can be hosted by each Issuer or Status Provider in a decentralised manner. Alternatively it can be hosted centrally both approaches have their benefits and drawbacks.

##### Decentralised
An Issuer or a Status Provider for the credentials issued can maintain a decentralised Status List. The Referenced Token will have the index and URI for the verifiers and the wallet to identify and check the Status List. This means each Issuer will need to create and maintain the Status List. The holder and the verifiers will need to access a different Status List for each credential.

###### Benefit
- A decentralised solution means that reduces blast radius to a single issuer related status in case of compromise or cyber attack
- Each Issuer will have the complete ownership of the solution they produce
- No inter-department replay mechanism should the service go down

###### Drawback
- Increases the work needed to become an Issuer
- Each Issuer needs to be competent building resilient infrastructure to support Status Updates and lookups
- Decreased anonymity and privacy of credentials issued
- Harder to get agreement to a single standard for Status List and more chances of deviating from a standard implementation
- Can result in varying levels of maturity in Issuer implementations

##### Centralised
A centralised GOV.UK service will be responsible for maintaining a Status List for all credentials issued by the Issuer. This service will only receive updates for the Status List in the form of an index and the updated Status Value. It will have no knowledge of the credential that references the status at the updated index. It will be the responsibility of the Issuer to maintain a reference to the credential and the status index. In the context of OAuth Status List this service will be the Status Provider. The Status List service must be sharded with multi-region and multi-cloud solution to address security, privacy and resilience.

###### Benefit
- This service will be built once and used by many
- Issuer does not require the expertise of maintaining the list, although the holder and verifiers will require knowledge of processing it correctly
- The Issuer is unable to track the holder as it is not aware of verifier activity

###### Drawback
- A decentralised solution means increased blast radius
- If the service is compromised or down it can effect all issuers, holders and verifiers

#### Functional and Non Functional requirements
- The should align to OAuth Status List RFC with support for 2 bit statuses
- Initially on Valid and Invalid statuses will be supported
- The statuses 
- The solution must scale out with sharded services and preserve anonymity by spreading indexes across the shards
- Deployment in different regions and cloud providers must be considered to increase redundancy and resilience

#### Interfaces
The service will have two issuer facing interfaces. One for issuance of status index and another for revocation. One public interface which handles get requests and responds with the status list.
More interfaces can be added in the future for other use-cases.

##### Issue
To get a new index the issuer must post a request including a expiry date for the credential. This date will be used to expire a slot for the index. The response from the service will be an index for the status and a URI of the list 

Example request
```
POST /issue HTTP/1.1
Host: api.status-list.service.gov.uk
Accept: application/json
{
  "expires": "1734709493852"
}
```
Example response
```
HTTP/1.1 200 OK
Content-Type: application/json
{
  "idx": "3",
  "URI": "https://api.status-list.service.gov.uk/statuslists/1"
}
```

##### Revoke
To revoke or set a credential `Status Type` to `INVALID` Issuer needs to Post a request to Revoke endpoint. The Issuer must sign the request for audit purpose. The response 

Example request
```
POST /revoke HTTP/1.1
Host: api.status-list.service.gov.uk
Accept: application/statuslist+jwt
Content-Type: application/json
{
  "idx": "3",
  "URI": "https://api.status-list.service.gov.uk/statuslists/1"
}
```
Example response with JWT status list.
```
HTTP/1.1 200 OK
Content-Type: application/statuslist+jwt

eyJhbGciOiJIUzI1NiIsImtpZCI6IjEyIiwidHlwIjoic3RhdHVzbGlzdCtqd3QifQ.eyJleHAiOjIyOTE3MjAxNzAsImlhdCI6MTY4NjkyMDE3MCwiaXNzIjoiaHR0cHM6Ly9hcGkuc3RhdHVzLWxpc3Quc2VydmljZS5nb3YudWsiLCJzdGF0dXNfbGlzdCI6eyJiaXRzIjoyLCJsc3QiOiJlTnB6ZEFFQUFNZ0FoZyJ9LCJzdWIiOiJodHRwczovL2FwaS5zdGF0dXMtbGlzdC5zZXJ2aWNlLmdvdi51ay9zdGF0dXNsaXN0cy8xIiwidHRsIjo0MzIwMH0.8bS1wn1TuHaN-RjDEyaf8cDLHH8m6IxgJT0qiLnxvqI
```
Decoded JWT
```
{
  "alg": "HS256",
  "kid": "12",
  "typ": "statuslist+jwt"
}
.
{
  "exp": 2291720170,
  "iat": 1686920170,
  "iss": "https://api.status-list.service.gov.uk",
  "status_list": {
    "bits": 2,
    "lst": "eNpzdAEAAMgAhg"
  },
  "sub": "https://api.status-list.service.gov.uk/statuslists/1",
  "ttl": 43200
}
```

##### Statuslists
This is the endpoint that will return the status list in response to a Get request. The response will have the Status List JWT as described by OAuth Status List including a ttl of 1-12 hours to allow caching the status list.

Example request
```
GET /statuslists/1 HTTP/1.1
Host: api.status-list.service.gov.uk
Accept: application/statuslist+jwt
```
Example response
```
HTTP/1.1 200 OK
Content-Type: application/statuslist+jwt

eyJhbGciOiJIUzI1NiIsImtpZCI6IjEyIiwidHlwIjoic3RhdHVzbGlzdCtqd3QifQ.eyJleHAiOjIyOTE3MjAxNzAsImlhdCI6MTY4NjkyMDE3MCwiaXNzIjoiaHR0cHM6Ly9hcGkuc3RhdHVzLWxpc3Quc2VydmljZS5nb3YudWsiLCJzdGF0dXNfbGlzdCI6eyJiaXRzIjoyLCJsc3QiOiJlTnB6ZEFFQUFNZ0FoZyJ9LCJzdWIiOiJodHRwczovL2FwaS5zdGF0dXMtbGlzdC5zZXJ2aWNlLmdvdi51ay9zdGF0dXNsaXN0cy8xIiwidHRsIjo0MzIwMH0.8bS1wn1TuHaN-RjDEyaf8cDLHH8m6IxgJT0qiLnxvqI
```

### Issuer Responsibility
The credential Issuer is responsible for creation of the credentials and the issuance of the Referenced Token. It will use the GOV.UK One Login Status List service as the Status Provider to get an index and URI to the status list. The Issuer must register with GOV.UK One Login so it can authenticate and then get access to the Status List issue and revoke APIs. The Issuer must ensure the correlation of credentials with indexes and lists as the Status Provider will not track this.  

### Holder Responsibility
The holder should use the public Status List API to get the status list referenced in the credential Referenced Token. The holder must use the correct URI and index from the credentials Referenced Token to fetch and then process the status list. The holder must perform the correct decoding and parsing of encoded Status List as mentioned in the [OAuth Status List RFC](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-06.html#name-correct-decoding-and-parsin). The holder may cache the status list for the duration of the ttl provided by the Status List provider. Once expired the holder must get the latest Status List.

### Verifier Responsibility
The verifier should use the public Status List API to get the status list referenced in the credential Referenced Token. The holder must use the correct URI and index from the credentials Referenced Token to fetch and then process the status list. The verifier must perform the correct decoding and parsing of encoded Status List as mentioned in the [OAuth Status List RFC](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-06.html#name-correct-decoding-and-parsin). The verifier may cache the status list for the duration of the ttl provided by the Status List provider. Once expired the holder must get the latest Status List.

## Open Questions

- What happens to credential that have been revoked permanently? Do they stay in the list forever? That will bloat the list over time. Perhaps the solution should be chunked status list with 

- Should the default value for the status list byte array be other than Zeros?
  Behaviour of the unused slots will be random and someone looking at the bit array should be unable to figure out by looking at the list and identify which bits are allocated and which one are not.
  Sharded bit arrays of for example 100 million slots to start off.
  Design consideration 100 shards of a million and so on.

- What mechanism do we use to rebuild the list when needed?

- Should we also record the issuer for every index to support Optional [Status List Aggregation](https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-06.html#name-status-list-aggregation) feature?
