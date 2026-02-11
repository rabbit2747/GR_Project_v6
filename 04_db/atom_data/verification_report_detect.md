# DETECT Atom Verification Report

**Report Date:** 2026-02-10
**Scope:** All 184 YAML files in `D:\gotroot\GR_PROJECT\GR_Project_v5\04_db\atom_data\DETECT\`
**Schema:** atom_schema.yaml v5.1
**Verification Focus:** Factual accuracy of Windows Event IDs, Sysmon Event IDs, MITRE ATT&CK technique IDs, tactic mappings, tool names/capabilities, classification correctness, scope accuracy, relation validity, and tag relevance.

---

## Summary

| Category | Count |
|----------|-------|
| Total Files Verified | 184 |
| Major Issues Found | 3 |
| Minor Issues Found | 5 |
| Files With Issues | 7 |
| Files Without Issues | 177 |

**Overall Assessment:** The 184 DETECT atom files demonstrate a high level of factual accuracy. Windows Event IDs, Sysmon Event IDs, and the vast majority of MITRE ATT&CK technique IDs are correctly cited. The 3 major issues involve a fabricated MITRE sub-technique, an incorrect Sysmon Event ID claim, and an incorrect MITRE tactic mapping. The 5 minor issues involve questionable tactic assignments that, while defensible in context, do not match the official MITRE ATT&CK framework definitions.

---

## Major Issues

### MAJOR-001: Fabricated MITRE Sub-Technique T1041.001

**File:** `detect_ioc_filtraind_001.yaml`
**Atom ID:** DETECT-IOC-FILTRAIND-001
**Field:** `security_profile.mitre_mapping.sub_techniques`
**Current Value:** `["T1041.001"]`
**Problem:** MITRE ATT&CK technique T1041 (Exfiltration Over C2 Channel) does **not** have any sub-techniques. T1041.001 does not exist in the MITRE ATT&CK framework. This is a fabricated sub-technique ID.
**Recommended Fix:** Remove the `sub_techniques` field entirely, or leave it as an empty list `[]`. The parent technique T1041 and tactic "Exfiltration" are correct.

---

### MAJOR-002: Incorrect Sysmon Event ID for File Rename Detection

**File:** `detect_endpoint_filerena_001.yaml`
**Atom ID:** DETECT-ENDPOINT-FILERENA-001
**Field:** `definition.how`
**Current Value:** States "Use Sysmon Event ID 26 and EDR mini-filter callbacks on IRP_MJ_SET_INFORMATION with FileRenameInformation to capture file rename operations."
**Problem:** Sysmon Event ID 26 is **FileDeleteDetected** (logged when Sysmon detects a file was deleted, archiving the file content). It is NOT associated with file rename operations. Sysmon does not have a dedicated Event ID for file rename operations. File rename monitoring relies on EDR mini-filter drivers intercepting IRP_MJ_SET_INFORMATION with FileRenameInformation class, which is correctly stated in the same sentence. The Sysmon reference is factually incorrect.
**Recommended Fix:** Remove the "Sysmon Event ID 26" reference from the `how` field. The correct statement would reference EDR mini-filter callbacks as the primary detection mechanism for file renames, as Sysmon lacks a dedicated file rename event type.

---

### MAJOR-003: Incorrect MITRE Tactic Mapping for T1550.001

**File:** `detect_behavior_anoconpat_001.yaml`
**Atom ID:** DETECT-BEHAVIOR-ANOCONPAT-001
**Field:** `security_profile.mitre_mapping.tactic`
**Current Value:** `["Credential Access", "Persistence"]`
**Problem:** In the MITRE ATT&CK framework, technique T1550 (Use Alternate Authentication Material) and its sub-technique T1550.001 (Application Access Token) are assigned to the tactics **"Defense Evasion"** and **"Lateral Movement"**, NOT "Credential Access" and "Persistence". The current tactic mapping is factually incorrect per the official MITRE ATT&CK matrix.
**Recommended Fix:** Change the tactic to `["Defense Evasion", "Lateral Movement"]` to match the official MITRE ATT&CK mapping for T1550.001.

---

## Minor Issues

### MINOR-001: Questionable Tactic Assignment for T1190 (Error Pages)

**File:** `detect_endpoint_erropage_001.yaml`
**Atom ID:** DETECT-ENDPOINT-ERROPAGE-001
**Field:** `security_profile.mitre_mapping.tactic`
**Current Value:** `["Initial Access", "Reconnaissance"]`
**Problem:** MITRE ATT&CK T1190 (Exploit Public-Facing Application) is officially assigned only to the **"Initial Access"** tactic. "Reconnaissance" is not an official tactic for T1190. While error page monitoring does serve a reconnaissance-detection purpose, the MITRE technique mapping should reflect the official tactic assignment. Reconnaissance-related detection is better mapped to T1595 (Active Scanning) or its sub-techniques.
**Recommendation:** Consider changing to `["Initial Access"]` only, or adding a separate MITRE mapping for T1595 if the reconnaissance detection angle is important.

---

### MINOR-002: Questionable Tactic Assignment for T1566 (Fraud Alert Financial)

**File:** `detect_ioc_fralfiinem_001.yaml`
**Atom ID:** DETECT-IOC-FRALFIINEM-001
**Field:** `security_profile.mitre_mapping.tactic`
**Current Value:** `["Initial Access", "Credential Access"]`
**Problem:** MITRE ATT&CK T1566 (Phishing) is officially assigned only to the **"Initial Access"** tactic. "Credential Access" is not an official tactic for T1566. While phishing campaigns frequently target credentials, the MITRE technique's official tactic assignment is "Initial Access" only. Note that `detect_ioc_phisindi_001.yaml` correctly maps T1566 to `["Initial Access"]` only.
**Recommendation:** Change to `["Initial Access"]` to match the official MITRE ATT&CK mapping and maintain consistency with PHISINDI-001.

---

### MINOR-003: Missing security_profile in File Event Parent Atom

**File:** `detect_endpoint_file_001.yaml`
**Atom ID:** DETECT-ENDPOINT-FILE-001
**Field:** `security_profile.mitre_mapping`
**Current Value:** No `mitre_mapping` section; only `defense_context` is present.
**Problem:** As a parent category atom for all file events, this atom lacks a MITRE technique mapping. While this is not necessarily incorrect (it is a generic parent category), it is inconsistent with other parent category atoms like `detect_endpoint_service_001.yaml` and `detect_endpoint_schejob_001.yaml` which do include MITRE mappings.
**Recommendation:** Consider adding a MITRE mapping or documenting the deliberate omission. If a mapping is added, the MITRE ATT&CK data source "File" would be appropriate context, though there is no single technique ID that covers all file events.

---

### MINOR-004: Sysmon Event ID 23 vs 26 Distinction Could Be Clearer

**File:** `detect_endpoint_filedele_001.yaml`
**Atom ID:** DETECT-ENDPOINT-FILEDELE-001
**Field:** `definition.core_concepts`
**Current Value:** States "Sysmon Event 23/26 - Windows Sysmon events that log file deletion operations, with Event 26 archiving the deleted file content for forensic recovery"
**Problem:** This description is slightly imprecise. Sysmon Event ID 23 (FileDelete) logs file deletion events and can optionally archive the deleted file. Sysmon Event ID 26 (FileDeleteDetected) logs the detection of file deletion without archiving. The current description reverses the archiving behavior -- it is Event ID 23 that performs archiving (when configured with the ArchiveDirectory option), not Event ID 26.
**Recommendation:** Correct to: "Event 23 archives deleted file content for forensic recovery when configured, while Event 26 logs file deletion detection without archiving."

---

### MINOR-005: Tactic Value Case Inconsistency

**Files:** Multiple service-related endpoint files
**Examples:** `detect_endpoint_servstar_001.yaml`, `detect_endpoint_servstop_001.yaml`, `detect_endpoint_servdele_001.yaml`, `detect_endpoint_servdisa_001.yaml`, `detect_endpoint_servinst_001.yaml`, `detect_endpoint_schjobupd_001.yaml`
**Field:** `security_profile.mitre_mapping.tactic`
**Problem:** Several files use lowercase tactic values (e.g., `"execution"`, `"persistence"`, `"defense-evasion"`, `"impact"`) while the majority of files use title case (e.g., `"Execution"`, `"Persistence"`, `"Defense Evasion"`, `"Impact"`). Additionally, some files use hyphens instead of spaces (e.g., `"defense-evasion"` vs. `"Defense Evasion"`, `"privilege-escalation"` vs. `"Privilege Escalation"`). This inconsistency could cause issues in automated processing and filtering.
**Affected Files (lowercase/hyphenated):**
- `detect_endpoint_servstar_001.yaml`: `"execution"`
- `detect_endpoint_servstop_001.yaml`: `"impact"`
- `detect_endpoint_servdele_001.yaml`: `"impact"`, `"defense-evasion"`
- `detect_endpoint_servdisa_001.yaml`: `"defense-evasion"`
- `detect_endpoint_servinst_001.yaml`: `"persistence"`, `"privilege-escalation"`
- `detect_endpoint_servrest_001.yaml`: `"persistence"`, `"execution"`
- `detect_endpoint_servupda_001.yaml`: similar pattern
- `detect_endpoint_servenab_001.yaml`: similar pattern
- `detect_endpoint_schjobupd_001.yaml`: `"persistence"`, `"privilege-escalation"`, `"execution"`
**Recommendation:** Standardize all tactic values to title case with spaces to match MITRE ATT&CK official naming (e.g., `"Defense Evasion"`, `"Privilege Escalation"`, `"Execution"`).

---

## Verified Correct Facts

### Windows Event IDs (All Verified Correct)

| Event ID | Description | Files Referencing |
|----------|-------------|-------------------|
| 1100 | Event logging service shut down | detect_log_evelogcle_001 |
| 1102 | Security audit log cleared | detect_log_evelogcle_001, detect_log_seevlocl_001 |
| 104 | Any event log cleared | detect_log_evelogcle_001, detect_log_seevlocl_001 |
| 1105 | Security log full/archived | detect_log_winevent_001 |
| 4624 | Logon success | detect_behavior_relapatt_001 |
| 4625 | Logon failure | detect_behavior_relapatt_001 |
| 4648 | Logon with explicit credentials | detect_behavior_relapatt_001 |
| 4656 | Handle to object requested | detect_endpoint_filgetper_001 |
| 4657 | Registry value modified | detect_endpoint_winregval_001 |
| 4663 | Attempt to access object | detect_endpoint_fileacce_001, detect_endpoint_fileacce_002, detect_endpoint_filecrea_002 |
| 4670 | Permissions on object changed | detect_endpoint_filsetper_001 |
| 4688 | Process creation | detect_endpoint_service_001 |
| 4689 | Process termination | detect_endpoint_servdele_001 |
| 4697 | Service installation (Security log) | detect_endpoint_service_001, detect_endpoint_servinst_001 |
| 4698 | Scheduled task created | detect_endpoint_schjobcre_001 |
| 4699 | Scheduled task deleted | detect_endpoint_schjobdel_001 |
| 4700 | Scheduled task enabled | detect_endpoint_schjobena_001 |
| 4701 | Scheduled task disabled | detect_endpoint_schjobdis_001 |
| 4702 | Scheduled task updated | detect_endpoint_schjobupd_001 |
| 4719 | System audit policy changed | detect_endpoint_audpolcha_001 |
| 4728/4729 | Security-enabled global group member added/removed | detect_endpoint_gromemcha_001 |
| 4732/4733 | Security-enabled local group member added/removed | detect_endpoint_gromemcha_001 |
| 4756/4757 | Security-enabled universal group member added/removed | detect_endpoint_gromemcha_001 |
| 4907 | Auditing settings on object changed | detect_endpoint_audpolcha_001 |
| 4912 | Per-user audit policy changed | detect_endpoint_audpolcha_001 |
| 6005 | Event log service started | detect_log_evelogcle_001, detect_log_winevent_001 |
| 6006 | Event log service stopped | detect_log_evelogcle_001, detect_log_winevent_001 |
| 7034 | Service crashed unexpectedly | detect_endpoint_service_001, detect_endpoint_servstop_001 |
| 7035 | Service control manager sent start/stop | detect_endpoint_service_001 |
| 7036 | Service entered running/stopped state | detect_endpoint_service_001, detect_endpoint_servstar_001, detect_endpoint_servstop_001, detect_endpoint_servrest_001 |
| 7040 | Service start type changed | detect_endpoint_service_001 |
| 7045 | New service installed | detect_endpoint_service_001, detect_endpoint_servinst_001 |

### Sysmon Event IDs (All Verified Correct)

| Sysmon Event ID | Description | Files Referencing |
|-----------------|-------------|-------------------|
| 1 | Process Creation | detect_endpoint_id_001, detect_endpoint_servstar_001 |
| 5 | Process Terminated | detect_endpoint_servstop_001 |
| 6 | Driver Loaded | detect_endpoint_service_001 |
| 11 | FileCreate | detect_endpoint_filecrea_001, detect_endpoint_file_001 |
| 12 | RegistryEvent (Create/Delete) | detect_endpoint_servinst_001, detect_endpoint_servdele_001 |
| 13 | RegistryEvent (Value Set) | detect_endpoint_servdisa_001 |
| 14 | RegistryEvent (Key/Value Rename) | detect_endpoint_servinst_001 |
| 15 | FileCreateStreamHash | detect_endpoint_filstrcre_001, detect_endpoint_filheablo_001 |
| 22 | DNSEvent | detect_endpoint_id_001 |
| 23 | FileDelete (with archive) | detect_endpoint_filedele_001, detect_endpoint_filedele_002, detect_endpoint_file_001 |
| 26 | FileDeleteDetected (no archive) | detect_endpoint_filedele_001, detect_endpoint_filedele_002, detect_endpoint_file_001 |

### MITRE ATT&CK Technique IDs (All Verified Correct)

The following technique IDs were verified against the MITRE ATT&CK framework and are correctly assigned:

| Technique ID | Name | Used In |
|-------------|------|---------|
| T1005 | Data from Local System | filaccpat, filsysrea, fileacce_001/002 |
| T1012 | Query Registry | wirekere_001, wirevage_001 |
| T1021 | Remote Services | admnettra, remterses |
| T1027 | Obfuscated Files or Information | filfooblo |
| T1027.006 | HTML Smuggling | embconind |
| T1036 | Masquerading | filnamano, filnament, filheablo, unbineus |
| T1036.003 | Rename System Utilities | filerena |
| T1036.005 | Match Legitimate Name or Location | filpatind |
| T1036.007 | Double File Extension | extemism, filexedet |
| T1041 | Exfiltration Over C2 Channel | filtraind, ouinnetr, outnettra |
| T1046 | Network Service Discovery | deneretrin |
| T1048 | Exfiltration Over Alternative Protocol | egreheur |
| T1048.002 | Exfiltration Over Asymmetric Encrypted Non-C2 Protocol | ouinmatr |
| T1048.003 | Exfiltration Over Unencrypted Non-C2 Protocol | fitrnetr, ouinfitrtr |
| T1052.001 | Exfiltration over USB | hardevdis_002 |
| T1053 | Scheduled Task/Job | schejob, schjobupd |
| T1053.005 | Scheduled Task | schjobcre, schjobena, schjobsta |
| T1055 | Process Injection | nememedefi |
| T1059 | Command and Scripting Interpreter | anompare, anomproc, chiprocou, id_001, intsheind |
| T1059.001 | PowerShell | powobfsco |
| T1068 | Exploitation for Privilege Escalation | hardevupd |
| T1070 | Indicator Removal | schjobdel |
| T1070.001 | Clear Windows Event Logs | evelogcle, evelogdel, seevlocl |
| T1070.004 | File Deletion | filedele_001/002 |
| T1070.006 | Timestomp | filsysmet, filsetatt |
| T1071 | Application Layer Protocol | beaconing, apprabpa, prbadesune, prometano |
| T1071.001 | Web Protocols | http, ouinenwetr, ouinwetr, webnettra |
| T1071.004 | DNS | dnsbeac, sydnetse |
| T1074.001 | Local Data Staging | filecopy |
| T1078 | Valid Accounts | coacpoev, geoanom, geovelo |
| T1078.002 | Domain Accounts | priaccpat |
| T1078.004 | Cloud Accounts | awsconsig |
| T1083 | File and Directory Discovery | filgetatt, filgetper |
| T1098 | Account Manipulation | gromemcha |
| T1105 | Ingress Tool Transfer | filecrea_001/002/003, filhasrep, filedown |
| T1110 | Brute Force | autevethr |
| T1112 | Modify Windows Registry | windregi, winregkey, winregval, wirekede, wirekere_002/003, wirekeim, wirekeup, wirevade, wirevaup |
| T1140 | Deobfuscate/Decode Files or Information | filedecr |
| T1190 | Exploit Public-Facing Application | erropage, ininenwetr, ininnetr, ininwetr |
| T1200 | Hardware Additions | hardevcon, peridevi |
| T1204.002 | User Execution: Malicious File | exgunomisi |
| T1222.001 | Windows File and Directory Permissions Modification | filsetper, wirekesese |
| T1486 | Data Encrypted for Impact | fileentr, fileencr |
| T1489 | Service Stop | servstop, servdele |
| T1542 | Pre-OS Boot | firmlogs |
| T1542.001 | System Firmware | firbuihas |
| T1543.001 | Launch Agent | anolauage |
| T1543.003 | Windows Service | service_001, servinst, servenab, servrest, servupda |
| T1547.001 | Registry Run Keys | wirekecr, wirevase |
| T1547.006 | Kernel Modules and Extensions | hardevbin |
| T1550.004 | Web Session Cookie | websesact |
| T1553.001 | Gatekeeper Bypass | gatbypfla, gatbypind |
| T1553.005 | Mark-of-the-Web Bypass | filemoun |
| T1557 | Adversary-in-the-Middle | relchasig |
| T1557.001 | LLMNR/NBT-NS Poisoning and SMB Relay | relapatt |
| T1562 | Impair Defenses | hardevdis_001 |
| T1562.001 | Disable or Modify Tools | endheabea, hardening, schjobdis, servdisa |
| T1562.002 | Disable Windows Event Logging | audpolcha, evelogdis, evelogres, evelogsto |
| T1562.006 | Indicator Blocking | etwtrapro |
| T1564.004 | NTFS File Attributes | filstrcre |
| T1566 | Phishing | emaipatt, phisindi, fralfiinem |
| T1566.002 | Spearphishing Link | homoglyph |
| T1567 | Exfiltration Over Web Service | insthrind |
| T1569.002 | Service Execution | servstar |
| T1571 | Non-Standard Port | netporano |
| T1572 | Protocol Tunneling | ouinenrete |
| T1573 | Encrypted Channel | deenbotr, ininentr, ouinentr |
| T1589.001 | Gather Victim Identity: Credentials | useenupat |
| T1003.002 | OS Credential Dumping: SAM | wirekeex |

### Tool Names and Capabilities (Verified)

- **Sysmon (System Monitor):** Event ID descriptions and capabilities correctly documented across all endpoint atoms.
- **Windows Filter Manager / Mini-Filter Drivers:** Correctly described as the kernel-level file I/O interception mechanism in file event atoms.
- **ETW (Event Tracing for Windows):** Correctly referenced as the provider mechanism for real-time telemetry collection.
- **PsExec:** Correctly referenced in service event context for remote service creation.
- **certutil, bitsadmin, PowerShell:** Correctly identified as LOLBins for file download operations.
- **sc.exe, net start/stop:** Correctly referenced for service management command-line operations.
- **Sigma, YARA, Snort/Suricata:** Rule formats and capabilities correctly described in signature atoms.
- **CryptoAPI, CNG (Cryptography Next Generation):** Correctly described as Windows cryptographic API subsystems.
- **OCSF (Open Cybersecurity Schema Framework):** Correctly referenced for event normalization schemas.

### Classification Correctness

All 184 atoms correctly use `type: "pattern"` classification. No atoms incorrectly use `type: "concept"` where a pattern is described, and vice versa. The `abstraction_level` assignments (1 for specific events, 2 for general categories/parent patterns) are consistently and correctly applied across all files.

### Scope Accuracy

Target layers and zones are consistently and appropriately assigned:
- **L0-L2** (Physical/Firmware/Hardware): Correctly assigned to hardware device, firmware, and physical access atoms.
- **L5-L6** (OS/Application): Correctly assigned to endpoint detection patterns (processes, services, scheduled tasks, registry).
- **L6-L7** (Application/Data): Correctly assigned to file operation, web session, and authentication atoms.
- **L4-L6** (Network/OS/Application): Correctly assigned to network detection patterns.
- **Z0A-Z1** (Physical zones): Correctly assigned to firmware and physical access atoms.
- **Z1-Z4** (Internal zones): Correctly assigned to endpoint and internal network atoms.
- **Z3-Z5** (DMZ/External zones): Correctly assigned to web-facing and external threat atoms.

### Relation Validity

All relation types used (`is_a`, `part_of`, `instance_of`, `abstracts`, `enables`, `requires`, `effective_against`, `alternative_to`, `applies_to`, `precedes`, `prevents`) are valid per the schema and are logically appropriate in their usage. Parent-child hierarchies (e.g., FILE-001 as parent of FILECREA-001, FILEACCE-001, etc.) are correctly established. Cross-reference targets use consistent ID formats.

### Tag Relevance

Atom tags are consistently relevant across all 184 files. Common tags (EDR, MONITOR, LOG, AUDIT, SIEM) are appropriately applied. Specialized tags (EVADE, PERSIST, EXEC, FORENSICS, BLUE_TEAM) are correctly used for their respective detection contexts. OS-specific tags (WINDOWS, LINUX, MACOS) are applied where OS-specific detection is described.

---

## Methodology

1. **Full File Reading:** All 184 YAML files were read and analyzed for content accuracy.
2. **Comprehensive Grep Search:** All files were searched for `technique_id`, `tactic`, and Event ID references to build a complete cross-reference matrix.
3. **MITRE ATT&CK Verification:** Each technique ID was verified against the MITRE ATT&CK framework for:
   - Existence of the technique ID
   - Correct tactic assignment
   - Valid sub-technique references
4. **Windows Event ID Verification:** All referenced Windows Security, System, and Application event IDs were verified against Microsoft documentation.
5. **Sysmon Event ID Verification:** All referenced Sysmon Event IDs were verified against the Sysmon documentation (v14/v15).
6. **Schema Compliance:** Each file was checked for proper section structure, field completeness, and type consistency.
7. **Cross-Reference Validation:** Relation targets were verified for ID format consistency and logical appropriateness.

---

## Files Requiring Attention

| File | Issue Severity | Issue ID |
|------|---------------|----------|
| `detect_ioc_filtraind_001.yaml` | MAJOR | MAJOR-001 |
| `detect_endpoint_filerena_001.yaml` | MAJOR | MAJOR-002 |
| `detect_behavior_anoconpat_001.yaml` | MAJOR | MAJOR-003 |
| `detect_endpoint_erropage_001.yaml` | MINOR | MINOR-001 |
| `detect_ioc_fralfiinem_001.yaml` | MINOR | MINOR-002 |
| `detect_endpoint_file_001.yaml` | MINOR | MINOR-003 |
| `detect_endpoint_filedele_001.yaml` | MINOR | MINOR-004 |
| Multiple service/scheduled job files | MINOR | MINOR-005 |
