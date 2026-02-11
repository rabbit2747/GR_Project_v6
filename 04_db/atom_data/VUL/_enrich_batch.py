#!/usr/bin/env python3
"""Batch enrichment script for VUL-MEMORY CVE atoms (items 11-46)."""
import os

BASE = os.path.dirname(os.path.abspath(__file__))

ATOMS = {

"vul_memory_cve20111255_001.yaml": """# GR Atom: CVE-2011-1255
# Schema: atom_schema.yaml v5.1
# Status: enriched

# ==== Section 1: Identity ====
identity:
  id: "VUL-MEMORY-CVE20111255-001"
  name: "CVE-2011-1255"
  normalized_name: "cve_2011_1255"
  aliases:
    - "Internet Explorer Time Element Use-After-Free"
    - "MS11-050"

# ==== Section 2: Classification ====
classification:
  is_infrastructure: false
  type: "vulnerability"
  abstraction_level: 1
  atom_tags:
    - EXEC
    - OVERFLOW
    - WINDOWS
    - WEB

# ==== Section 4: Scope (non-INFRA only) ====
scope:
  target_layers: ["L7"]
  target_zones: ["Z2", "Z3"]
  target_components:
    - "Internet Explorer 8"
    - "Internet Explorer 9"
    - "mshtml.dll"

# ==== Section 5: Definition ====
definition:
  what: >-
    CVE-2011-1255 (CVSS 9.3) is a use-after-free vulnerability in Microsoft Internet Explorer
    8 and 9 related to improper handling of time elements in the DOM. When IE processes a web
    page containing specific HTML time elements that are created and deleted in a particular
    sequence, a use-after-free condition occurs in mshtml.dll enabling arbitrary code execution.
    Patched in MS11-050 (June 2011). Exploited in targeted attacks.
  why: >-
    Internet Explorer was the dominant web browser in enterprise environments, making IE
    use-after-free vulnerabilities prime targets for both targeted attacks and exploit kits.
    This vulnerability exemplified the growing trend of DOM manipulation exploits in IE that
    would continue for several more years.
  how: >-
    The vulnerability is triggered via a specially crafted web page that creates time elements
    in the DOM, manipulates their properties, and then removes them while internal references
    persist. When IE subsequently accesses the freed DOM object, attacker-controlled data
    occupies the freed memory, enabling code execution via heap spray techniques.
  core_concepts:
    - key: "IE DOM Use-After-Free"
      value: "Time element manipulation causes freed DOM object access in mshtml.dll enabling heap-based exploitation"
    - key: "Browser Exploitation Era"
      value: "Part of the widespread IE use-after-free vulnerability class exploited in both targeted attacks and exploit kits"

# ==== Section 6: Relations ====
relations:
  - type: "is_a"
    target: "VUL-MEMORY-CVE20124792-001"
    description: "Both are Internet Explorer use-after-free vulnerabilities in DOM element handling"
  - type: "applies_to"
    target: "INFRA-OS-WINDOWS-001"
    description: "Affects Internet Explorer on Windows platforms"

# ==== Section 7: Security Profile ====
security_profile:
  mitre_mapping:
    technique_id: "T1189"
    tactic:
      - "Initial Access"

# ==== Section 8: Metadata ====
metadata:
  created: "2026-02-06"
  updated: "2026-02-10"
  version: "1.0"
  confidence: "high"
  trust_source: "authoritative"
  sources:
    - "Microsoft Security Bulletin MS11-050"
    - "CVE-2011-1255 - NIST NVD"
    - "MITRE ATT&CK T1189 - Drive-by Compromise"
  search_keywords:
    - "CVE-2011-1255"
    - "MS11-050"
    - "IE use-after-free"
    - "Internet Explorer time element"
    - "mshtml.dll vulnerability"
    - "IE DOM exploit"
  embedding_text: >-
    CVE-2011-1255 is a use-after-free vulnerability (CVSS 9.3) in Internet Explorer 8/9 DOM
    time element handling (MS11-050). Improper management of time elements in mshtml.dll
    causes freed object access enabling arbitrary code execution via heap spray. Part of
    the widespread IE use-after-free vulnerability class exploited in targeted attacks and
    exploit kits during the peak of browser-based exploitation.
""",

"vul_memory_cve20112005_001.yaml": """# GR Atom: CVE-2011-2005
# Schema: atom_schema.yaml v5.1
# Status: enriched

# ==== Section 1: Identity ====
identity:
  id: "VUL-MEMORY-CVE20112005-001"
  name: "CVE-2011-2005"
  normalized_name: "cve_2011_2005"
  aliases:
    - "Windows Ancillary Function Driver Privilege Escalation"
    - "MS11-080"
    - "AFD.sys Local Privilege Escalation"

# ==== Section 2: Classification ====
classification:
  is_infrastructure: false
  type: "vulnerability"
  abstraction_level: 1
  atom_tags:
    - PRIV
    - OVERFLOW
    - WINDOWS
    - OS

# ==== Section 4: Scope (non-INFRA only) ====
scope:
  target_layers: ["L1", "L2"]
  target_zones: ["Z3"]
  target_components:
    - "Windows Ancillary Function Driver (afd.sys)"
    - "Windows XP SP3"
    - "Windows Server 2003 SP2"

# ==== Section 5: Definition ====
definition:
  what: >-
    CVE-2011-2005 (CVSS 7.2) is a privilege escalation vulnerability in the Windows Ancillary
    Function Driver (afd.sys) affecting Windows XP SP3 and Server 2003 SP2. The vulnerability
    exists in improper validation of user-supplied input when handling specific IOCTL requests,
    causing a buffer overflow in kernel memory that enables local attackers to execute code with
    SYSTEM privileges. Patched in MS11-080 (October 2011).
  why: >-
    afd.sys is a kernel driver that handles Winsock operations and is present on all Windows
    systems. This vulnerability provided reliable local privilege escalation and was used in
    conjunction with remote code execution vulnerabilities to achieve full system compromise
    in multi-stage attack chains.
  how: >-
    The vulnerability is triggered by sending specially crafted IOCTL requests to the AFD driver
    that contain manipulated buffer length parameters. The driver fails to properly validate
    these parameters, causing a kernel pool buffer overflow. The attacker controls the overflow
    to corrupt adjacent kernel pool allocations, gaining arbitrary kernel-mode code execution.
  core_concepts:
    - key: "AFD.sys Kernel IOCTL"
      value: "Ancillary Function Driver fails to validate IOCTL request parameters causing kernel pool overflow"
    - key: "Kernel Pool Corruption"
      value: "Controlled kernel pool overflow enables corruption of adjacent allocations for privilege escalation"

# ==== Section 6: Relations ====
relations:
  - type: "is_a"
    target: "VUL-MEMORY-CVE20081084-001"
    description: "Both are Windows kernel driver privilege escalation vulnerabilities via buffer overflow"
  - type: "applies_to"
    target: "INFRA-OS-WINDOWS-001"
    description: "Affects Windows XP and Server 2003 kernel"

# ==== Section 7: Security Profile ====
security_profile:
  mitre_mapping:
    technique_id: "T1068"
    tactic:
      - "Privilege Escalation"

# ==== Section 8: Metadata ====
metadata:
  created: "2026-02-06"
  updated: "2026-02-10"
  version: "1.0"
  confidence: "high"
  trust_source: "authoritative"
  sources:
    - "Microsoft Security Bulletin MS11-080"
    - "CVE-2011-2005 - NIST NVD"
    - "MITRE ATT&CK T1068 - Exploitation for Privilege Escalation"
  search_keywords:
    - "CVE-2011-2005"
    - "MS11-080"
    - "afd.sys"
    - "AFD privilege escalation"
    - "Windows kernel pool overflow"
    - "Winsock driver vulnerability"
  embedding_text: >-
    CVE-2011-2005 is a privilege escalation vulnerability (CVSS 7.2) in Windows Ancillary
    Function Driver afd.sys (MS11-080). Improper validation of IOCTL request parameters
    causes kernel pool buffer overflow enabling SYSTEM-level code execution. Affects Windows
    XP SP3 and Server 2003 SP2. Used in multi-stage attack chains combining remote code
    execution with local privilege escalation for full system compromise.
""",

"vul_memory_cve20112462_001.yaml": """# GR Atom: CVE-2011-2462
# Schema: atom_schema.yaml v5.1
# Status: enriched

identity:
  id: "VUL-MEMORY-CVE20112462-001"
  name: "CVE-2011-2462"
  normalized_name: "cve_2011_2462"
  aliases:
    - "Adobe Reader U3D Memory Corruption"
    - "APSB11-30"
    - "Adobe Reader Universal 3D Zero-Day"

classification:
  is_infrastructure: false
  type: "vulnerability"
  abstraction_level: 1
  atom_tags:
    - EXEC
    - OVERFLOW
    - WINDOWS
    - INITIAL

scope:
  target_layers: ["L7"]
  target_zones: ["Z2", "Z3"]
  target_components:
    - "Adobe Reader 9.x and X (10.x)"
    - "Adobe Acrobat 9.x and X (10.x)"
    - "U3D (Universal 3D) component"

definition:
  what: >-
    CVE-2011-2462 (CVSS 10.0) is a critical memory corruption vulnerability in the U3D
    (Universal 3D) component of Adobe Reader and Acrobat. A specially crafted PDF containing
    malformed U3D data triggers a heap buffer overflow enabling arbitrary code execution.
    Exploited as a zero-day in targeted attacks against defense contractors. Patched in
    APSB11-30 and APSB12-01 (December 2011/January 2012).
  why: >-
    This zero-day targeted defense and government organizations via spearphishing with
    weaponized PDF documents. The U3D format support in Adobe Reader introduced complex
    parsing code that was rarely audited, creating a fertile attack surface. The vulnerability
    demonstrated ongoing risks of supporting complex multimedia formats in document readers.
  how: >-
    The vulnerability exists in the U3D mesh parsing code where malformed mesh continuation
    block data causes a heap buffer overflow. Exploitation delivers a crafted PDF via
    spearphishing. When opened in Adobe Reader, the malformed U3D object triggers the overflow,
    and heap spray techniques provide reliable code execution.
  core_concepts:
    - key: "U3D Format Parsing Overflow"
      value: "Malformed Universal 3D mesh data in PDF causes heap buffer overflow in Adobe Reader U3D component"
    - key: "Defense Sector Targeting"
      value: "Zero-day specifically used to target defense contractors and government organizations via spearphishing"

relations:
  - type: "is_a"
    target: "VUL-MEMORY-CVE20094324-001"
    description: "Both are Adobe Reader zero-days exploited in targeted spearphishing campaigns"
  - type: "enables"
    target: "VUL-MEMORY-CVE20114369-001"
    description: "Related Adobe Reader vulnerability used in coordinated attack campaigns"

security_profile:
  mitre_mapping:
    technique_id: "T1203"
    tactic:
      - "Execution"
      - "Initial Access"

metadata:
  created: "2026-02-06"
  updated: "2026-02-10"
  version: "1.0"
  confidence: "high"
  trust_source: "authoritative"
  sources:
    - "Adobe Security Bulletin APSB11-30"
    - "CVE-2011-2462 - NIST NVD"
    - "MITRE ATT&CK T1203 - Exploitation for Client Execution"
  search_keywords:
    - "CVE-2011-2462"
    - "APSB11-30"
    - "Adobe Reader U3D"
    - "PDF zero-day"
    - "Universal 3D vulnerability"
    - "Adobe Reader heap overflow"
  embedding_text: >-
    CVE-2011-2462 is a critical memory corruption (CVSS 10.0) in Adobe Reader/Acrobat U3D
    component (APSB11-30). Malformed Universal 3D mesh data in PDF documents triggers heap
    buffer overflow enabling arbitrary code execution. Exploited as zero-day targeting defense
    contractors via spearphishing. Demonstrates risks of complex multimedia format support
    in document readers.
""",

"vul_memory_cve20113544_001.yaml": """# GR Atom: CVE-2011-3544
# Schema: atom_schema.yaml v5.1
# Status: enriched

identity:
  id: "VUL-MEMORY-CVE20113544-001"
  name: "CVE-2011-3544"
  normalized_name: "cve_2011_3544"
  aliases:
    - "Oracle Java Rhino Script Engine Sandbox Bypass"
    - "Java SE Rhino Vulnerability"

classification:
  is_infrastructure: false
  type: "vulnerability"
  abstraction_level: 1
  atom_tags:
    - EXEC
    - OVERFLOW
    - WINDOWS
    - WEB

scope:
  target_layers: ["L7"]
  target_zones: ["Z2", "Z3"]
  target_components:
    - "Oracle Java SE JDK/JRE 7 and 6 Update 27"
    - "Java Rhino Script Engine"
    - "Java browser plugin"

definition:
  what: >-
    CVE-2011-3544 (CVSS 10.0) is a critical vulnerability in the Rhino Script Engine component
    of Oracle Java SE that allows untrusted Java applets to bypass the security sandbox and
    execute arbitrary code. The vulnerability affects Java JDK/JRE 7 and 6 Update 27 and earlier.
    Widely exploited in drive-by download attacks and exploit kits. Patched in Oracle Critical
    Patch Update October 2011.
  why: >-
    Java browser plugins were installed on hundreds of millions of computers. Java sandbox
    bypass vulnerabilities were devastating because they enabled untrusted code from websites
    to execute with full system privileges. This CVE became one of the most exploited
    vulnerabilities in exploit kits like Blackhole and Cool.
  how: >-
    The vulnerability exists in the Rhino script engine where a specially crafted JavaScript
    executed within a Java applet context can bypass security manager checks. A malicious
    web page loads a Java applet that uses the Rhino engine to escalate from sandboxed to
    unrestricted execution. Exploit kits widely adopted this for automated mass exploitation.
  core_concepts:
    - key: "Java Sandbox Bypass"
      value: "Rhino Script Engine allows untrusted applets to bypass security sandbox for unrestricted code execution"
    - key: "Exploit Kit Integration"
      value: "Widely integrated into Blackhole, Cool, and other exploit kits for automated mass exploitation"

relations:
  - type: "precedes"
    target: "VUL-MEMORY-CVE20124681-001"
    description: "Part of the series of Java sandbox bypass vulnerabilities heavily used in exploit kits"
  - type: "applies_to"
    target: "INFRA-OS-WINDOWS-001"
    description: "Primarily exploited on Windows via Java browser plugin"

security_profile:
  mitre_mapping:
    technique_id: "T1189"
    tactic:
      - "Initial Access"
      - "Execution"

metadata:
  created: "2026-02-06"
  updated: "2026-02-10"
  version: "1.0"
  confidence: "high"
  trust_source: "authoritative"
  sources:
    - "Oracle Critical Patch Update - October 2011"
    - "CVE-2011-3544 - NIST NVD"
    - "MITRE ATT&CK T1189 - Drive-by Compromise"
  search_keywords:
    - "CVE-2011-3544"
    - "Java Rhino"
    - "Java sandbox bypass"
    - "exploit kit Java"
    - "Blackhole exploit"
    - "Java applet exploit"
  embedding_text: >-
    CVE-2011-3544 is a critical Java sandbox bypass (CVSS 10.0) in the Rhino Script Engine
    component of Oracle Java SE. Untrusted Java applets bypass security manager to execute
    arbitrary code with full system privileges. Widely adopted by Blackhole and Cool exploit
    kits for automated mass exploitation via drive-by download attacks. Affects JDK/JRE 7
    and 6u27 and earlier.
""",

"vul_memory_cve20114369_001.yaml": """# GR Atom: CVE-2011-4369
# Schema: atom_schema.yaml v5.1
# Status: enriched

identity:
  id: "VUL-MEMORY-CVE20114369-001"
  name: "CVE-2011-4369"
  normalized_name: "cve_2011_4369"
  aliases:
    - "Adobe Reader PRC Component Memory Corruption"
    - "APSB12-01"

classification:
  is_infrastructure: false
  type: "vulnerability"
  abstraction_level: 1
  atom_tags:
    - EXEC
    - OVERFLOW
    - WINDOWS
    - INITIAL

scope:
  target_layers: ["L7"]
  target_zones: ["Z2", "Z3"]
  target_components:
    - "Adobe Reader 9.x and X (10.x)"
    - "Adobe Acrobat 9.x and X (10.x)"
    - "PRC (Product Representation Compact) component"

definition:
  what: >-
    CVE-2011-4369 (CVSS 10.0) is a critical memory corruption vulnerability in the PRC
    component of Adobe Reader and Acrobat. Specially crafted PRC data embedded in PDF documents
    triggers memory corruption enabling arbitrary code execution. Exploited in conjunction with
    CVE-2011-2462 in coordinated targeted attacks. Patched in APSB12-01 (January 2012).
  why: >-
    This vulnerability was part of a coordinated campaign exploiting multiple Adobe Reader
    zero-days simultaneously to maximize attack success probability. The PRC format, like U3D,
    represents complex 3D content support that expanded the PDF attack surface significantly.
  how: >-
    A crafted PDF containing malformed PRC (Product Representation Compact) data triggers
    memory corruption in Adobe Reader's PRC handling code. Combined with heap spraying, the
    corruption enables reliable code execution when a victim opens the PDF attachment.
  core_concepts:
    - key: "PRC Format Memory Corruption"
      value: "Malformed PRC 3D data in PDF documents triggers memory corruption in Adobe Reader PRC component"
    - key: "Coordinated Zero-Day Campaign"
      value: "Used alongside CVE-2011-2462 in coordinated attacks exploiting multiple Reader vulnerabilities simultaneously"

relations:
  - type: "requires"
    target: "VUL-MEMORY-CVE20112462-001"
    description: "Used in coordinated campaigns alongside U3D vulnerability for maximum attack effectiveness"
  - type: "applies_to"
    target: "INFRA-OS-WINDOWS-001"
    description: "Affects Adobe Reader on Windows platforms"

security_profile:
  mitre_mapping:
    technique_id: "T1203"
    tactic:
      - "Execution"
      - "Initial Access"

metadata:
  created: "2026-02-06"
  updated: "2026-02-10"
  version: "1.0"
  confidence: "high"
  trust_source: "authoritative"
  sources:
    - "Adobe Security Bulletin APSB12-01"
    - "CVE-2011-4369 - NIST NVD"
    - "MITRE ATT&CK T1203 - Exploitation for Client Execution"
  search_keywords:
    - "CVE-2011-4369"
    - "APSB12-01"
    - "Adobe Reader PRC"
    - "PDF memory corruption"
    - "PRC vulnerability"
    - "Adobe Reader zero-day"
  embedding_text: >-
    CVE-2011-4369 is a critical memory corruption (CVSS 10.0) in Adobe Reader/Acrobat PRC
    component (APSB12-01). Malformed PRC 3D data in PDF documents triggers memory corruption
    enabling arbitrary code execution. Used in coordinated campaigns alongside CVE-2011-2462
    targeting defense organizations. Complex 3D format support in PDF readers creates expanded
    attack surface for targeted exploitation.
""",

"vul_memory_cve20120158_001.yaml": """# GR Atom: CVE-2012-0158
# Schema: atom_schema.yaml v5.1
# Status: enriched

identity:
  id: "VUL-MEMORY-CVE20120158-001"
  name: "CVE-2012-0158"
  normalized_name: "cve_2012_0158"
  aliases:
    - "MSCOMCTL.OCX ListView Memory Corruption"
    - "MS12-027"
    - "MSCOMCTL ActiveX Buffer Overflow"

classification:
  is_infrastructure: false
  type: "vulnerability"
  abstraction_level: 1
  atom_tags:
    - EXEC
    - OVERFLOW
    - WINDOWS
    - INITIAL

scope:
  target_layers: ["L7"]
  target_zones: ["Z2", "Z3"]
  target_components:
    - "MSCOMCTL.OCX ActiveX control"
    - "Microsoft Office 2003/2007/2010"
    - "Windows Common Controls"

definition:
  what: >-
    CVE-2012-0158 (CVSS 9.3) is a critical stack buffer overflow in the MSCOMCTL.OCX ActiveX
    control (Windows Common Controls) that is loaded by Microsoft Office applications. A
    specially crafted Office document containing a malformed ListView control triggers the
    overflow enabling arbitrary code execution. This became one of the most exploited
    vulnerabilities globally, used by virtually every APT group for years. Patched in
    MS12-027 (April 2012).
  why: >-
    CVE-2012-0158 was the single most exploited vulnerability in targeted attacks for multiple
    years running. Its reliability, ease of exploitation, and the universal presence of Office
    made it the default weapon for spearphishing campaigns worldwide. The vulnerability remained
    heavily exploited long after patching due to slow enterprise update cycles.
  how: >-
    The vulnerability is in MSCOMCTL.OCX when processing a ListView control embedded in an
    Office document. A malformed control header specifies an incorrect size, causing a stack
    buffer overflow when the control data is parsed. ROP chains bypass DEP/ASLR for reliable
    exploitation across Office versions. Delivered via RTF or DOC files in spearphishing.
  core_concepts:
    - key: "MSCOMCTL ListView Overflow"
      value: "ActiveX common control buffer overflow via malformed ListView header in Office documents"
    - key: "Most Exploited CVE"
      value: "Became the single most exploited vulnerability in targeted attacks globally for multiple consecutive years"
    - key: "Universal APT Weapon"
      value: "Adopted by virtually every APT group worldwide as the default spearphishing exploitation vector"

relations:
  - type: "supersedes"
    target: "VUL-MEMORY-CVE20103333-001"
    description: "Replaced RTF pFragments as the dominant Office exploitation vector for APT campaigns"
  - type: "precedes"
    target: "VUL-MEMORY-CVE20151641-001"
    description: "Office document exploitation pattern continued with later Word and RTF vulnerabilities"
  - type: "applies_to"
    target: "INFRA-OS-WINDOWS-001"
    description: "Affects Microsoft Office on Windows platforms via MSCOMCTL.OCX"

security_profile:
  mitre_mapping:
    technique_id: "T1203"
    tactic:
      - "Execution"
      - "Initial Access"

metadata:
  created: "2026-02-06"
  updated: "2026-02-10"
  version: "1.0"
  confidence: "high"
  trust_source: "authoritative"
  sources:
    - "Microsoft Security Bulletin MS12-027"
    - "CVE-2012-0158 - NIST NVD"
    - "MITRE ATT&CK T1203 - Exploitation for Client Execution"
  search_keywords:
    - "CVE-2012-0158"
    - "MS12-027"
    - "MSCOMCTL.OCX"
    - "ListView buffer overflow"
    - "ActiveX exploit"
    - "most exploited CVE"
    - "Office spearphishing"
  embedding_text: >-
    CVE-2012-0158 is a critical stack buffer overflow (CVSS 9.3) in MSCOMCTL.OCX ActiveX
    control (MS12-027). Malformed ListView control headers in Office documents trigger stack
    overflow enabling arbitrary code execution. The single most exploited vulnerability in
    targeted attacks globally for multiple years. Adopted by virtually every APT group for
    spearphishing campaigns. Affects Office 2003-2010 on Windows.
""",
}

for fname, content in ATOMS.items():
    path = os.path.join(BASE, fname)
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(content)
    print(f"OK: {fname}")

print(f"\\nWrote {len(ATOMS)} files")
