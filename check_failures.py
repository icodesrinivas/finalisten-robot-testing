import xml.etree.ElementTree as ET

def check_results(xml_path):
    tree = ET.parse(xml_path)
    root = tree.getroot()
    
    for status_type in ["FAIL", "SKIP"]:
        found = []
        for test in root.findall(".//test"):
            status = test.find("status")
            if status is not None and status.get("status") == status_type:
                name = test.get("name")
                msg = status.text.strip().split('\n')[0] if status.text else "No message"
                found.append((name, msg))
        
        print(f"\n--- {status_type} TESTS ({len(found)}) ---")
        for name, msg in found:
            print(f"- {name}: {msg}")

if __name__ == "__main__":
    check_results('robot-results/output.xml')
