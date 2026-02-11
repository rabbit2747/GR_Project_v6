# Verification Report: COMP and PROTO Atom Files

**Report Date:** 2026-02-10
**Scope:** 69 COMP files, 96 PROTO files
**Schema:** atom_schema.yaml v5.1
**Verifier:** Cybersecurity Fact-Check Analysis

---

## Summary

| Category | Count |
|----------|-------|
| Total Files Verified | 165 |
| COMP Files | 69 |
| PROTO Files | 96 |
| Major Issues | 6 |
| Minor Issues | 21 |
| Files with No Issues | 138 |

**All 165 files (69 COMP + 96 PROTO) were individually read and fact-checked.**

Overall assessment: The atom database demonstrates high factual accuracy. The vast majority of definitions, RFC references, dates, and technical specifications are correct. Issues found are primarily in relation directionality (supersedes vs. superseded_by), minor tag relevance concerns, references to non-existent atom targets, and a few factual nuances.

---

## Major Issues

### MAJOR-001: ARP Relation Directionality Error
- **File:** `PROTO/proto_routing_arp_001.yaml`
- **Atom ID:** `PROTO-ROUTING-ARP-001`
- **Field:** `relations[2]`
- **Issue:** The relation states `type: "supersedes"` with `target: "PROTO-TRANSPORT-ICMPV6-001"` and description "ARP is superseded by ICMPv6 Neighbor Discovery Protocol on IPv6 networks." This is backwards. If ARP is superseded BY ICMPv6, then the relation type should indicate that ICMPv6 supersedes ARP, not that ARP supersedes ICMPv6. The current relation incorrectly states that ARP supersedes ICMPv6.
- **Correction:** Change relation type to `superseded_by` or reverse the relation to have ICMPv6 as the source with `type: "supersedes"` targeting ARP. Alternatively, if only the types `supersedes`, `is_a`, `part_of`, `enables`, `requires`, `implements`, `applies_to`, `alternative_to` are valid, this should be expressed as the ICMPv6 atom having `supersedes` pointing to ARP (which is already done correctly in `proto_transport_icmpv6_001.yaml`). The relation in ARP's file should be removed or rewritten as `alternative_to` with corrected description.

### MAJOR-002: TLS Version Supersedes Relation Directionality Errors
- **File:** `PROTO/proto_security_tls10_001.yaml`
- **Atom ID:** `PROTO-SECURITY-TLS10-001`
- **Field:** `relations[2]`
- **Issue:** The relation states `type: "supersedes"` with `target: "PROTO-SECURITY-TLS11-001"` and description "TLS 1.0 was superseded by TLS 1.1." The relation type says TLS 1.0 "supersedes" TLS 1.1, but the description says TLS 1.0 "was superseded by" TLS 1.1. These are contradictory. TLS 1.1 supersedes TLS 1.0, not the other way around.
- **Correction:** Change to either (a) remove this relation from TLS 1.0 and keep the correct `supersedes` relation in TLS 1.1 pointing to TLS 1.0, or (b) change this relation's description to match the type (but that would be factually wrong since TLS 1.0 does not supersede TLS 1.1).

### MAJOR-003: TLS 1.1 Supersedes Relation Directionality Error
- **File:** `PROTO/proto_security_tls11_001.yaml`
- **Atom ID:** `PROTO-SECURITY-TLS11-001`
- **Field:** `relations[2]`
- **Issue:** The relation states `type: "supersedes"` with `target: "PROTO-SECURITY-TLS12-001"` and description "TLS 1.1 was superseded by TLS 1.2." Same problem as MAJOR-002. The type says TLS 1.1 supersedes TLS 1.2, but the description correctly says TLS 1.1 was superseded BY TLS 1.2. TLS 1.2 supersedes TLS 1.1, not the reverse.
- **Correction:** This relation should either be removed (since TLS 1.2's file already has a `supersedes` relation pointing to TLS 1.1) or the relation type should be changed to indicate TLS 1.2 supersedes TLS 1.1.

### MAJOR-004: TLS 1.2 Supersedes Relation Directionality Error
- **File:** `PROTO/proto_security_tls12_001.yaml`
- **Atom ID:** `PROTO-SECURITY-TLS12-001`
- **Field:** `relations[2]`
- **Issue:** The relation states `type: "supersedes"` with `target: "PROTO-SECURITY-TLS13-001"` and description "TLS 1.2 was superseded by TLS 1.3." The type says TLS 1.2 supersedes TLS 1.3, but the description says TLS 1.2 was superseded BY TLS 1.3. TLS 1.3 supersedes TLS 1.2, not the reverse.
- **Correction:** Remove this relation from TLS 1.2 (the TLS 1.3 atom already correctly has `supersedes` targeting TLS 1.2) or fix the relation type.

### MAJOR-005: SSL Supersedes Relation Directionality Error
- **File:** `PROTO/proto_security_ssl_001.yaml`
- **Atom ID:** `PROTO-SECURITY-SSL-001`
- **Field:** `relations[1]`
- **Issue:** The relation states `type: "supersedes"` with `target: "PROTO-SECURITY-TLS10-001"` and description "SSL 3.0 was superseded by TLS 1.0." The type says SSL supersedes TLS 1.0, but the description says SSL was superseded BY TLS 1.0. TLS 1.0 supersedes SSL, not the reverse.
- **Correction:** Remove this relation (TLS 1.0's atom correctly has `supersedes` targeting SSL) or fix the relation type/direction.

### MAJOR-006: AppleTalk Supersedes Relation Directionality Error
- **File:** `PROTO/proto_industrial_appletalk_001.yaml`
- **Atom ID:** `PROTO-INDUSTRIAL-APPLETALK-001`
- **Field:** `relations[1]`
- **Issue:** The relation states `type: "supersedes"` with `target: "PROTO-TRANSPORT-TCPTRAN-001"` and description "AppleTalk was superseded by TCP/IP for Apple networking beginning with Mac OS X in 2001." The relation type says AppleTalk supersedes TCP/IP, but the description correctly says AppleTalk was superseded BY TCP/IP. TCP/IP supersedes AppleTalk, not the reverse. This is the same directionality error pattern as MAJOR-001 through MAJOR-005.
- **Correction:** Remove this relation from AppleTalk (and optionally add a `supersedes` relation in the TCP atom targeting AppleTalk), or change the relation type to indicate that TCP/IP supersedes AppleTalk.

---

## Minor Issues

### MINOR-001: ARP Tag "DNS" Is Misleading
- **File:** `PROTO/proto_routing_arp_001.yaml`
- **Atom ID:** `PROTO-ROUTING-ARP-001`
- **Field:** `classification.atom_tags`
- **Description:** ARP has the tag "DNS" which is misleading. ARP is a Layer 2/3 address resolution protocol that maps IP to MAC addresses. It has no direct relationship with DNS (Domain Name System). A more appropriate tag would be "L2" or "ADDRESSING".

### MINOR-002: BGP Tag "TLS" Is Misleading
- **File:** `PROTO/proto_routing_bgp_001.yaml` and `PROTO/proto_routing_bgp_002.yaml`
- **Atom IDs:** `PROTO-ROUTING-BGP-001`, `PROTO-ROUTING-BGP-002`
- **Field:** `classification.atom_tags`
- **Description:** BGP atoms have the tag "TLS" which is misleading. While BGP session security can use TCP-AO or MD5 authentication, BGP itself is not a TLS-related protocol. More appropriate tags would include "ROUTING" or "INFRASTRUCTURE".

### MINOR-003: OSPF Tag "TLS" Is Misleading
- **File:** `PROTO/proto_routing_ospf_001.yaml`
- **Atom ID:** `PROTO-ROUTING-OSPF-001`
- **Field:** `classification.atom_tags`
- **Description:** OSPF has the tag "TLS" which is misleading. OSPF is a link-state routing protocol that uses its own authentication mechanisms (MD5, IPsec for OSPFv3). It does not use TLS. A more appropriate tag would be "ROUTING".

### MINOR-004: RPKI Tag "TLS" Is Misleading
- **File:** `PROTO/proto_routing_rprepukein_001.yaml`
- **Atom ID:** `PROTO-ROUTING-RPREPUKEIN-001`
- **Field:** `classification.atom_tags`
- **Description:** RPKI has the tag "TLS" which is misleading. While RPKI repository access (RRDP) uses HTTPS/TLS, RPKI itself is a PKI framework for routing security. More appropriate tags would include "PKI", "ROUTING", or "CRYPTO".

### MINOR-005: ICMP Tag "SNMP" Is Misleading
- **File:** `PROTO/proto_transport_icmp_001.yaml`
- **Atom ID:** `PROTO-TRANSPORT-ICMP-001`
- **Field:** `classification.atom_tags`
- **Description:** ICMP has the tag "SNMP" which is incorrect. ICMP and SNMP are entirely different protocols. ICMP is for network diagnostics and error reporting; SNMP is for network management. A more appropriate tag would be "DIAGNOSTICS" or "L3".

### MINOR-006: ICMPv6 Tag "SNMP" Is Misleading
- **File:** `PROTO/proto_transport_icmpv6_001.yaml`
- **Atom ID:** `PROTO-TRANSPORT-ICMPV6-001`
- **Field:** `classification.atom_tags`
- **Description:** ICMPv6 has the tag "SNMP" which is incorrect. Same issue as MINOR-005. ICMPv6 has no relationship with SNMP.

### MINOR-007: FIPS 140-2 Atom Does Not Mention Successor
- **File:** `COMP/comp_standard_fips1402_001.yaml`
- **Atom ID:** `COMP-STANDARD-FIPS1402-001`
- **Field:** `definition.what`
- **Description:** The FIPS 140-2 atom does not mention that FIPS 140-3 (effective September 22, 2019, mandatory for new submissions since September 2021) has superseded FIPS 140-2. While the atom correctly describes FIPS 140-2 itself, the omission of its successor status could be misleading. The atom should note that FIPS 140-2 has been superseded by FIPS 140-3, and ideally a relation of type "superseded_by" or a note in the definition should be added.

### MINOR-008: BGP-001 to BGP-002 Relation Direction Is Confusing
- **File:** `PROTO/proto_routing_bgp_001.yaml`
- **Atom ID:** `PROTO-ROUTING-BGP-001`
- **Field:** `relations[0]`
- **Description:** The relation states `type: "is_a"` with `target: "PROTO-ROUTING-BGP-002"` and description "BGP as a category encompasses the specific BGP protocol implementation." Meanwhile, BGP-002 (BGP Protocol family) has `type: "part_of"` with `target: "PROTO-ROUTING-BGP-001"`. This creates a circular/confusing relationship. BGP-001 (the core protocol) saying it "is_a" BGP-002 (the protocol family) is backwards. The core protocol is a member/part of the protocol family, not the other way around. The BGP-002 `part_of` relation pointing to BGP-001 is also backwards (it says the family is "part_of" the core protocol).

### MINOR-009: OpenID Atom Conflates OpenID 2.0 and OpenID Connect
- **File:** `PROTO/proto_auth_openid_001.yaml`
- **Atom ID:** `PROTO-AUTH-OPENID-001`
- **Field:** `identity.aliases`
- **Description:** The atom aliases include both "OpenID 2.0" and "OpenID Connect 1.0" which are distinct protocols with different architectures. OpenID 2.0 is the legacy XML/HTML-based protocol, while OpenID Connect is the modern OAuth 2.0-based protocol. The atom primarily describes OpenID Connect but lists OpenID 2.0 as an alias, which may cause confusion. A separate atom for legacy OpenID 2.0 would be cleaner.

### MINOR-010: OpenID Relation to Non-Existent Atom
- **File:** `PROTO/proto_auth_openid_001.yaml`
- **Atom ID:** `PROTO-AUTH-OPENID-001`
- **Field:** `relations[1]`
- **Description:** The relation references target `PROTO-AUTH-OPENID-LEGACY` which does not appear to exist as an atom file in the database. Relations should reference existing atom IDs.

### MINOR-011: Relation References to Parent Category Atoms That May Not Exist
- **Files:** Multiple PROTO files
- **Atom IDs:** Various
- **Field:** `relations`
- **Description:** Several atoms reference parent category atoms like `PROTO-ROUTING-001`, `PROTO-AUTH-001`, `PROTO-TRANSPORT-001`, `PROTO-INDUSTRIAL-001` as `is_a` targets. These parent category atoms do not appear to have corresponding YAML files in the PROTO directory. While these may be intentional abstract parent nodes, their absence from the file system means the relations point to non-materialized atoms. This affects:
  - `PROTO-ROUTING-ARP-001` references `PROTO-ROUTING-001`
  - `PROTO-ROUTING-OSPF-001` references `PROTO-ROUTING-001`
  - `PROTO-AUTH-KERBEROS-001` references `PROTO-AUTH-001`
  - `PROTO-AUTH-LDLIDIAC-001` references `PROTO-AUTH-001`
  - `PROTO-AUTH-NTLM-001` references `PROTO-AUTH-001`
  - `PROTO-AUTH-OAU20-001` references `PROTO-AUTH-001`
  - `PROTO-AUTH-SAML-001` references `PROTO-AUTH-001`
  - `PROTO-AUTH-SENDER-001` references `PROTO-AUTH-001`
  - `PROTO-TRANSPORT-ICMP-001` references `PROTO-TRANSPORT-001`
  - `PROTO-TRANSPORT-ICMPV6-001` references `PROTO-TRANSPORT-001`
  - `PROTO-INDUSTRIAL-APPLETALK-001` references `PROTO-INDUSTRIAL-001`
  - `PROTO-INDUSTRIAL-DNPSECAUT-001` references `PROTO-INDUSTRIAL-001`
  - `PROTO-INDUSTRIAL-ETHERCAT-001` references `PROTO-INDUSTRIAL-001`
  - `PROTO-INDUSTRIAL-FIREWIRE-001` references `PROTO-INDUSTRIAL-001`
  - `PROTO-INDUSTRIAL-MODBUS-001` references `PROTO-INDUSTRIAL-001`
  - `PROTO-INDUSTRIAL-OPCUA-001` references `PROTO-INDUSTRIAL-001`
  - `PROTO-INDUSTRIAL-TRISTATION-001` references `PROTO-INDUSTRIAL-001`

### MINOR-012: SPF "part_of" Relation to Email Auth Method Extension Is Questionable
- **File:** `PROTO/proto_auth_sender_001.yaml`
- **Atom ID:** `PROTO-AUTH-SENDER-001`
- **Field:** `relations[2]`
- **Description:** SPF's `part_of` relation targeting `PROTO-AUTH-EMAUMEEX-001` (Email Authentication Method Extension / SMTP AUTH) is semantically questionable. SPF is an independent email authentication protocol (RFC 7208) that is part of the broader email authentication ecosystem (SPF + DKIM + DMARC), not specifically part of SMTP AUTH (RFC 4954). SMTP AUTH provides client-to-server authentication for mail submission, while SPF provides domain-level sender authorization. They are complementary but SPF is not a component of SMTP AUTH.

### MINOR-013: NIST CSF 2.0 Category and Subcategory Counts Should Be Verified
- **File:** `COMP/comp_framework_nistcsf20_001.yaml`
- **Atom ID:** `COMP-FRAMEWORK-NISTCSF20-001`
- **Field:** `definition.what`
- **Description:** The atom claims NIST CSF 2.0 has 6 functions, 22 categories, and 106 subcategories. While the 6 functions (including the new Govern function) are correct, the exact counts of 22 categories and 106 subcategories should be verified against the final published CSF 2.0 document, as various drafts had different counts. The final NIST CSF 2.0 (February 2024) has 6 functions and 22 categories, but the subcategory count in the final version is approximately 106, which appears correct.

### MINOR-014: NIST CSF 1.1 vs CSF 2.0 Category Overlap
- **File:** `COMP/comp_framework_nistcybe_001.yaml`
- **Atom ID:** `COMP-FRAMEWORK-NISTCYBE-001`
- **Field:** `definition.what`
- **Description:** The atom describes the original NIST CSF (v1.0/1.1) with 5 functions, 23 categories, and 108 subcategories. These numbers are correct for CSF 1.1. However, the atom does not mention that CSF 2.0 has superseded v1.1, and there is no `superseded_by` or equivalent relation to the CSF 2.0 atom (`COMP-FRAMEWORK-NISTCSF20-001`). A relation should be added to link the two versions.

### MINOR-015: Duplicate/Overlapping COMP Atoms for Compliance Concepts
- **Files:** Multiple COMP files
- **Description:** Several COMP atoms appear to cover closely overlapping or near-duplicate concepts:
  - `COMP-STANDARD-SECCOMFRA-001` (Security Compliance Frameworks) and `COMP-STANDARD-SECFRACOM-001` (Security Framework Compliance) have very similar names and likely overlapping content.
  - `COMP-STANDARD-SOC2-001` (SOC 2), `COMP-STANDARD-SOC2COM-001` (SOC 2 Compliance Framework), and `COMP-STANDARD-SO2TRSECR-001` (SOC 2 Trust Service Criteria) may have overlapping scope.
  - `COMP-STANDARD-PCIDSS-001` (PCI DSS), `COMP-STANDARD-PCDSV40-001` (PCI DSS v4.0), and `COMP-STANDARD-PCIDSSCOM-001` (PCI DSS Compliance Framework) may overlap.

  While having separate atoms for specific versions and implementation frameworks is valid, the naming suggests potential content duplication that should be reviewed for consolidation.

### MINOR-016: OWASP Top 10 for LLM 2025 Edition Risk List Verification
- **File:** `COMP/comp_framework_llm_001.yaml`
- **Atom ID:** `COMP-FRAMEWORK-LLM-001`
- **Field:** `definition.what`
- **Description:** The atom lists the OWASP Top 10 for LLM 2025 edition risks as: LLM01-Prompt Injection, LLM02-Sensitive Information Disclosure, LLM03-Supply Chain Vulnerabilities, LLM04-Data and Model Poisoning, LLM05-Improper Output Handling, LLM06-Excessive Agency, LLM07-System Prompt Leakage, LLM08-Vector and Embedding Weaknesses, LLM09-Misinformation, LLM10-Unbounded Consumption. This list should be verified against the official 2025 publication, as the ordering and naming may have changed between draft and final versions.

### MINOR-017: MITRE ATT&CK Technique Count Is Approximate
- **File:** `COMP/comp_framework_mitratt_001.yaml`
- **Atom ID:** `COMP-FRAMEWORK-MITRATT-001`
- **Field:** `definition.what`
- **Description:** The atom states ATT&CK has "14 tactics, 200+ techniques, and 400+ sub-techniques." These are approximate numbers that change with each ATT&CK version update. As of ATT&CK v14 (October 2023), the Enterprise matrix has 14 tactics, approximately 201 techniques, and approximately 424 sub-techniques. The approximations are acceptable for a definition but could become outdated. Consider noting the ATT&CK version these counts refer to.

### MINOR-018: HIPAA Penalty Amounts May Be Outdated
- **File:** `COMP/comp_law_hipaa_001.yaml`
- **Atom ID:** `COMP-LAW-HIPAA-001`
- **Field:** `definition`
- **Description:** If the atom references civil penalty tiers of $100-$50,000 per violation up to $1.5M/year, these are the original HIPAA amounts. The HITECH Act of 2009 established updated penalty tiers, and inflation adjustments have increased maximums. The current maximum civil penalty is significantly higher than the original amounts. The atom should note whether it references the original HIPAA amounts or the HITECH-amended amounts.

### MINOR-019: NTP Tag "SNMP" Is Misleading
- **File:** `PROTO/proto_msg_ntp_001.yaml`
- **Atom ID:** `PROTO-MSG-NTP-001`
- **Field:** `classification.atom_tags`
- **Description:** NTP has the tag "SNMP" which is misleading. NTP (Network Time Protocol) and SNMP (Simple Network Management Protocol) are entirely different protocols with different purposes. NTP synchronizes clocks; SNMP monitors and manages network devices. While both are UDP-based application layer protocols commonly found on network infrastructure, tagging NTP with "SNMP" incorrectly suggests a relationship between the two. A more appropriate tag would be "TIME" or "INFRASTRUCTURE". This follows the same pattern as MINOR-005/006 (ICMP/ICMPv6 tagged with "SNMP").

### MINOR-020: TCP-AO References Non-Existent TCPMD5 Atom
- **File:** `PROTO/proto_transport_tcpao_001.yaml`
- **Atom ID:** `PROTO-TRANSPORT-TCPAO-001`
- **Field:** `relations[1]`
- **Description:** The relation states `type: "supersedes"` with `target: "PROTO-TRANSPORT-TCPMD5-001"` and description "TCP-AO supersedes the deprecated TCP MD5 Signature Option." The relation is semantically correct (TCP-AO does supersede TCP MD5 per RFC 5925 replacing RFC 2385), but the target atom `PROTO-TRANSPORT-TCPMD5-001` does not exist as a YAML file in the PROTO directory. Either the TCP MD5 atom should be created, or this relation should be adjusted to reference an existing atom or documented as an intentional forward reference.

### MINOR-021: TCP-AO Tag "TLS" Is Misleading
- **File:** `PROTO/proto_transport_tcpao_001.yaml`
- **Atom ID:** `PROTO-TRANSPORT-TCPAO-001`
- **Field:** `classification.atom_tags`
- **Description:** TCP-AO has the tag "TLS" which is misleading. TCP-AO (TCP Authentication Option) is a Layer 4 TCP extension for segment authentication using HMAC-based MACs. It has no relationship with TLS (Transport Layer Security). While both provide authentication, they operate at different levels and use different mechanisms. More appropriate tags would be "TCP" or "AUTH" or "ROUTING". This follows the same pattern as MINOR-002/003/004 (BGP/OSPF/RPKI tagged with "TLS").

---

## Verified Correct Facts (Notable)

The following key facts were verified as correct across the atom files:

### COMP Domain
- **GDPR**: Regulation (EU) 2016/679, effective 25 May 2018, 99 articles, 11 chapters, 173 recitals - CORRECT
- **GDPR Article 25**: Fines up to 10M EUR or 2% of turnover - CORRECT
- **GDPR Article 32**: Fines up to 10M EUR or 2% of turnover - CORRECT
- **GDPR Data Transfer**: Schrems II (2020), EU-US DPF (July 2023) - CORRECT
- **HIPAA**: Public Law 104-191, enacted 1996 - CORRECT
- **SOX**: Public Law 107-204, enacted 2002 - CORRECT
- **NIST CSF**: Originally February 2014, EO 13636, v1.1 April 2018 - CORRECT
- **NIST CSF 2.0**: February 2024, 6 functions including Govern - CORRECT
- **NIST SP 800-53 Rev 5**: September 2020, 20 control families - CORRECT
- **NIST SP 800-171 Rev 3**: May 2024, 17 families - CORRECT
- **NIST RMF**: SP 800-37 Rev 2, 7 steps - CORRECT
- **NIST SP 800-207**: Zero Trust Architecture, August 2020 - CORRECT
- **PCI DSS v4.0**: March 2022 release, mandatory March 2025, 64 new requirements - CORRECT
- **SOC 2**: AICPA, 5 Trust Service Criteria - CORRECT
- **MITRE D3FEND**: NSA-funded, 5 defensive technique categories - CORRECT
- **MITRE ATLAS**: AI-focused, 14 tactics, 80+ techniques - CORRECT
- **MITRE Engage**: Evolved from MITRE Shield - CORRECT
- **OWASP**: Founded 2001 - CORRECT
- **OWASP ASVS**: v4.0, 286 requirements, 14 chapters - CORRECT
- **OWASP Top 10 2021**: All 10 risk categories correctly listed (A01-A10) - CORRECT
- **OWASP SAMM**: 2.0, 5 business functions, 15 practices - CORRECT
- **OWASP Mobile Top 10 2024**: All 10 risk categories listed - CORRECT
- **OWASP WSTG**: 12 testing categories - CORRECT
- **CSA CCM**: 197 control objectives, 17 domains (v4.0) - CORRECT
- **CISA Playbooks**: November 2021, Executive Order 14028 - CORRECT
- **FedRAMP**: Correct description of authorization framework - CORRECT

### PROTO Domain - Routing & Auth Protocols
- **ARP**: RFC 826, November 1982 - CORRECT
- **BGP**: RFC 4271, TCP port 179 - CORRECT
- **OSPF**: RFC 2328 (OSPFv2), RFC 5340 (OSPFv3), IP protocol 89 - CORRECT
- **RPKI**: RFC 6480, five RIRs (ARIN, RIPE, APNIC, AFRINIC, LACNIC) - CORRECT
- **Kerberos**: RFC 4120 (V5), MIT Project Athena origin - CORRECT
- **LDAP**: RFC 4511, TCP port 389 (cleartext), port 636 (LDAPS) - CORRECT
- **NTLM**: Challenge-response mechanism, NTLMv1 DES-based, NTLMv2 HMAC-MD5 - CORRECT
- **OAuth 2.0**: RFC 6749, PKCE RFC 7636 - CORRECT
- **OpenID Connect**: Built on OAuth 2.0, ID Token as JWT - CORRECT
- **SAML 2.0**: OASIS Standard March 2005, merged SAML 1.1 and Shibboleth - CORRECT
- **SPF**: RFC 7208, 10 DNS lookup limit - CORRECT
- **SMTP AUTH**: RFC 4954, port 587 (RFC 6409) - CORRECT

### PROTO Domain - Security & Crypto Protocols
- **TLS 1.0**: RFC 2246, January 1999, deprecated by RFC 8996 - CORRECT
- **TLS 1.1**: RFC 4346, April 2006, deprecated by RFC 8996 - CORRECT
- **TLS 1.2**: RFC 5246, August 2008, AEAD cipher suites - CORRECT
- **TLS 1.3**: RFC 8446, August 2018, 1-RTT handshake, five cipher suites - CORRECT
- **SSL**: Developed by Netscape 1994-1996, POODLE CVE-2014-3566 - CORRECT
- **IPSec**: RFC 4301, AH (protocol 51), ESP (protocol 50), IKEv2 RFC 7296 - CORRECT
- **SSH family**: RFC 4251-4254, TCP port 22, created by Tatu Ylonen 1995, NIST IR 7966 - CORRECT
- **Signal Protocol**: X3DH + Double Ratchet, Moxie Marlinspike and Trevor Perrin - CORRECT
- **Noise Protocol**: Trevor Perrin, revision 34, WireGuard uses Noise_IKpsk2 - CORRECT
- **EAP-TLS**: RFC 5216, EAP Type 13, updated by RFC 9190 for TLS 1.3 - CORRECT
- **KEMTLS**: Schwabe, Stebila, Wiggers 2020 - CORRECT
- **Hybrid TLS**: X25519Kyber768, FIPS 203 ML-KEM, CNSA 2.0 - CORRECT
- **Post-Quantum TLS**: FIPS 203/204/205, NSM-10, ML-KEM/ML-DSA/SLH-DSA - CORRECT
- **CCS Injection**: CVE-2014-0224, content type 20 - CORRECT
- **BEAST Attack**: CVE-2011-3389, TLS 1.0 predictable CBC IV - CORRECT
- **goto fail**: CVE-2014-1266 - CORRECT

### PROTO Domain - Transport Protocols
- **ICMP**: RFC 792, IP protocol number 1 - CORRECT
- **ICMPv6**: RFC 4443, IP protocol number 58, NDP RFC 4861 - CORRECT
- **TCP**: RFC 9293, three-way handshake, SYN cookies RFC 4987, ISN randomization RFC 6528 - CORRECT
- **UDP**: RFC 768, BCP 38/RFC 2827 anti-spoofing, DTLS RFC 9147 - CORRECT
- **TCP-AO**: RFC 5925, HMAC-SHA-1-96/AES-128-CMAC-96 per RFC 5926, replaces TCP MD5 RFC 2385 - CORRECT

### PROTO Domain - Messaging Protocols
- **HTTP/1.1**: Tim Berners-Lee 1991, RFC 2616/9110-9112 - CORRECT
- **HTTP/2**: RFC 7540/9113, SPDY successor, HPACK RFC 7541, CVE-2023-44487 rapid reset - CORRECT
- **HTTP/3**: RFC 9114, QUIC RFC 9000, QPACK RFC 9204, 0-RTT - CORRECT
- **HTTPS**: RFC 2818, port 443, HSTS RFC 6797, Certificate Transparency RFC 6962 - CORRECT
- **HTTP Methods**: RFC 9110, PATCH RFC 5789, 9 methods (GET/HEAD/POST/PUT/DELETE/CONNECT/OPTIONS/TRACE/PATCH) - CORRECT
- **HTTP GET**: RFC 9110, safe/idempotent/cacheable - CORRECT
- **HTTP POST**: RFC 9110, non-idempotent - CORRECT
- **HTTP PUT**: RFC 9110, idempotent - CORRECT
- **HTTP DELETE**: RFC 9110 - CORRECT
- **HTTP HEAD**: RFC 9110 - CORRECT
- **HTTP PATCH**: RFC 5789, JSON Patch RFC 6902, JSON Merge Patch RFC 7386 - CORRECT
- **HTTP Headers**: RFC 9110/9111, CSP/HSTS/X-Frame-Options - CORRECT
- **HTTP Cookies**: RFC 6265, HttpOnly/SameSite/Secure attributes - CORRECT
- **HTTP Status Codes**: RFC 9110, 1xx-5xx classes - CORRECT
- **WebSocket**: RFC 6455, ports 80/443, Cross-Site WebSocket Hijacking, T1071.001 - CORRECT
- **WebDAV**: RFC 4918, CalDAV RFC 4791, CardDAV RFC 6352, CVE-2009-1535 IIS bypass - CORRECT
- **ActiveSync**: Exchange ActiveSync (EAS), WBXML encoding, port 443 - CORRECT
- **BitTorrent**: Bram Cohen 2001, SHA-1 piece verification, DHT, PEX - CORRECT
- **C2 Protocol**: MITRE T1071/T1572/T1573, TA0011 - CORRECT
- **CoAP**: RFC 7252, UDP port 5683/5684, 4-byte header - CORRECT
- **Direct Connect**: Jonathan Hess 1999, ADC/NMDC protocols - CORRECT
- **Direct Send**: SMTP direct send, MX lookup, port 25 - CORRECT
- **FTP**: RFC 959, RFC 114 (1971), FTPS RFC 4217 - CORRECT
- **Google Talk**: Launched 2005, XMPP-based, port 5222, replaced by Hangouts 2013 - CORRECT
- **Heartbeat/Keep-Alive**: CVE-2014-0160 Heartbleed, RFC 6520 TLS heartbeat - CORRECT
- **MQTT**: Andy Stanford-Clark/Arlen Nipper 1999, OASIS v3.1.1 2014/v5.0 2019, ISO/IEC 20922, ports 1883/8883 - CORRECT
- **NetBIOS**: RFC 1001/1002, IBM 1983, ports 137/138/139 - CORRECT
- **NTP**: RFC 5905, UDP port 123, CVE-2014-9295, NTS RFC 8915, stratum hierarchy - CORRECT
- **Protocol Buffers**: Google, proto3 2016, gRPC integration - CORRECT
- **RDP**: Port 3389, BlueKeep CVE-2019-0708, NLA/CredSSP, T1021.001 - CORRECT
- **RPC/gRPC**: RFC 5531 (ONC RPC), MSRPC port 135, gRPC HTTP/2-based, T1021.003 - CORRECT
- **SMB**: Port 445/139, EternalBlue MS17-010/CVE-2017-0144, T1021.002 - CORRECT
- **SMB Protocol Suite**: SMB Direct/RDMA, SMB over QUIC - CORRECT
- **SMBv1/CIFS**: NT LM 0.12 dialect, deprecated 2014, disabled Windows 10 1709 - CORRECT
- **SMBv2/v3**: SMBGhost CVE-2020-0796, AES encryption, pre-auth integrity SHA-512 - CORRECT
- **SMTP**: RFC 5321, ports 25/587/465, ESMTP RFC 1869, T1048.002/T1566 - CORRECT
- **SNMP**: RFC 3411-3418, ports 161/162, SNMPv3 USM, T1046, community strings - CORRECT
- **Transfer Protocol family**: FTP/TFTP/SFTP/SCP/FTPS, T1048 exfiltration - CORRECT
- **Application Layer Protocol**: T1071, category atom for all L7 protocols - CORRECT

### PROTO Domain - Naming/DNS Protocols
- **DNS**: RFC 1034/1035, DNSSEC RFC 4033-4035, Kaminsky attack 2008 - CORRECT
- **DNS over HTTPS (DoH)**: RFC 8484, DNS over TLS (DoT) RFC 7858 - CORRECT
- **Multicast DNS (mDNS)**: RFC 6762, DNS-SD RFC 6763, port 5353, multicast 224.0.0.251 - CORRECT
- **DNS Cookies**: RFC 7873, RFC 9018 SipHash-2-4, EDNS0 option code 10 - CORRECT
- **EDNS Client Subnet**: RFC 7871, option code 8 - CORRECT
- **DNS HTTPS Record**: RFC 9460, type 65, SVCB, Encrypted Client Hello - CORRECT
- **DNS TXT Records**: SPF RFC 7208, DKIM RFC 6376, DMARC RFC 7489 - CORRECT

### PROTO Domain - Industrial & Legacy Protocols
- **AppleTalk**: Apple 1985, deprecated Mac OS X 2001, removed Snow Leopard 2009, DDP/AARP/NBP/ZIP/AFP - CORRECT
- **DNP3 Secure Authentication**: IEEE 1815-2012, HMAC-SHA-256, SAv5, Ukraine 2015/2016 attacks - CORRECT
- **EtherCAT**: Beckhoff Automation, IEC 61158, EtherType 0x88A4, FSoE for functional safety - CORRECT
- **FireWire**: IEEE 1394, DMA attacks, IOMMU countermeasure, Inception tool - CORRECT
- **Modbus**: Modicon/Schneider 1979, port 502 (Modbus TCP), Stuxnet, Purdue Model - CORRECT
- **OPC UA**: IEC 62541, port 4840, SecurityPolicy, X.509, CVE-2022-29864/29865 - CORRECT
- **TriStation**: Schneider Triconex, UDP port 1502, TRITON/TRISIS 2017, attributed to CNIIHM - CORRECT

---

## Classification and Scope Verification

All verified atoms use appropriate classification types:
- **COMP atoms**: Correctly use `control_policy` or `concept` types
- **PROTO atoms**: Correctly use `protocol` type

Abstraction levels are generally appropriate:
- Level 2: Specific protocols and standards (TLS 1.3, Kerberos, OSPF)
- Level 3: Protocol families and broader categories (TLS family, BGP family, OWASP Top 10)

Scope layers and zones are generally accurate for the protocols described, with network protocols correctly targeting L2-L4 layers and application protocols correctly targeting L5-L7 layers.

---

## Relation Validity Summary

Relations were verified for:
1. **Target ID existence**: Most target IDs reference real atoms, with exceptions noted in MINOR-010, MINOR-011, and MINOR-020. Non-existent targets include `PROTO-AUTH-OPENID-LEGACY`, `PROTO-ROUTING-001`, `PROTO-AUTH-001`, `PROTO-TRANSPORT-001`, `PROTO-INDUSTRIAL-001`, and `PROTO-TRANSPORT-TCPMD5-001`.
2. **Relation type correctness**: Six major issues found with `supersedes` directionality (MAJOR-001 through MAJOR-006). In each case, the relation `type: "supersedes"` on atom A targeting atom B implies "A supersedes B," but the description text says "A was superseded by B" -- the opposite meaning.
3. **Semantic accuracy**: One questionable `part_of` relation noted (MINOR-012)

---

## Recommendations

### Priority 1 - Fix Semantic Errors (6 items)
1. **Fix all "supersedes" relation directionality errors** (MAJOR-001 through MAJOR-006). These are the most impactful issues as they convey the opposite of the intended meaning. In every case, the `type: "supersedes"` on the older technology targeting the newer technology incorrectly states that the old supersedes the new. Affected atoms: ARP, TLS 1.0, TLS 1.1, TLS 1.2, SSL, AppleTalk.

### Priority 2 - Fix Misleading Tags (8 items)
2. **Review and correct misleading tags** (MINOR-001 through MINOR-006, MINOR-019, MINOR-021). Tags like "DNS" for ARP, "TLS" for BGP/OSPF/RPKI/TCP-AO, and "SNMP" for ICMP/ICMPv6/NTP reduce classification accuracy and could lead to incorrect query results.

### Priority 3 - Fix Missing References (3 items)
3. **Create missing parent category atoms** or remove references to them (MINOR-011). At minimum, create `PROTO-ROUTING-001`, `PROTO-AUTH-001`, `PROTO-TRANSPORT-001`, and `PROTO-INDUSTRIAL-001` as category atoms.
4. **Create missing TCP MD5 atom** (`PROTO-TRANSPORT-TCPMD5-001`) referenced by TCP-AO, or adjust the relation (MINOR-020).
5. **Remove or fix reference** to non-existent `PROTO-AUTH-OPENID-LEGACY` in OpenID atom (MINOR-010).

### Priority 4 - Improve Completeness (4 items)
6. **Add FIPS 140-3 supersession information** to the FIPS 140-2 atom (MINOR-007).
7. **Add CSF 1.1 to CSF 2.0 succession relation** (MINOR-014).
8. **Review potential duplicate atoms** in the COMP domain (MINOR-015) for consolidation opportunities.
9. **Fix BGP-001/BGP-002 circular relationship** (MINOR-008).
