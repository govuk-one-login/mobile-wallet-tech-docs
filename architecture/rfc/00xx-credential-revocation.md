# RFC 00XX Credential Revocation

## Background
GOV.UK One Login is developing a government wallet - GOV.UK One Login digital wallet - to enable users to acquire, view and share digital versions of government-issued credentials. It is useful for an issuer to also include an link to a location where the holder and verifier of the credential can confirm the current status of the credential. This document will explore the options for the revocation mechanism required to keep the issuer, holder and verifier up to date with the credential status.

## Requirements

GOV.UK One Login or an issuer may want to revoke credential(s) they have issued.

- The revocation may be permanent or temporary depending on the scenario.
- The revocation must support at least 4 statuses, Valid, Invalid, Suspended and Application specific.
- The revocation mechanism must be secure, privacy preserving and scalable to millions of records.

Some example scenarios are 

- Revoking a driving license as a result of disqualification.
- Issuance of a new licence to replace a learning licence.

## Scope

This RFC builds on the [IETF Oauth Status List RFC](https://datatracker.ietf.org/doc/draft-ietf-oauth-status-list/06/) and focuses on the use of status list to provide up to date statuses for the GOV.UK One Login wallet issuer, holder and verifier.

## References to other design documents

## Options

### IETF OAuth Status List

### W3C Bitstring Status List

In a [Bitstring Status List](https://www.w3.org/TR/vc-bitstring-status-list/) The status information of a verifiable credential issue by the issuer is represented as items in a list. Each issuer manages a list of all verifiable credentials that it has issued. Each verifiable credential is associated with an item in its list. When a single bit specifies a status, such as "revoked" or "suspended", then that status is expected to be true when the bit is set (1) and false when unset (0).

An individual bit represents a status when the bit is set (1) the status is true for the associated credential. When the bit is unset (0) the status is not false for the credential. A simple example below shows a StatusListCredential with bit at index `94567` representing the `revocation` status for credential at URL "https://example.com/credentials/status/3". Similarly bit at index 23452 represents the "suspension" status of the credential at URL "https://example.com/credentials/status/4".

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

Pros
data compression - highly compressible using run-length compression techniques such as GZIP [RFC1952](https://www.rfc-editor.org/rfc/rfc1952).
The status list is expressed inside a verifiable credential in order to enable a holder to provide it directly to a verifier.

Cons
Bitstring Status List is a W3C Candidate Draft and is not a standard yet.
The working group might change the specification, for example `TTL` conflicts with `validUntil` and it might be removed in the future.

###  Certificate Revocation Lists (CRL)
[RFC5280](https://www.rfc-editor.org/rfc/rfc5280)

## Solution Design

Privacy

One to one correlation between the status and the holder of credential. The status updates must not result in tracking of the holder of the driving licence for example when they 

> What happens to credential that have been revoked permamnently? Do they stay in the list forever? That will bloat the list over time.

### Proposed Solution

#### Centralised Vs Decentralised List

### Issuer

### Holder

### Verifier
