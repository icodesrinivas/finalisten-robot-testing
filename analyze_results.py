import xml.etree.ElementTree as ET
import sys

def analyze_failures(xml_file):
    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
        for t in root.iter('test'):
            status = t.find('status')
            if status is not None and status.get('status') == 'FAIL':
                name = t.get('name')
                msg = status.text if status.text else "No message"
                print(f"FAILED: {name}")
                print(f"ERROR: {msg}")
                print("-" * 40)
    except Exception as e:
        print(f"Error parsing XML: {e}")

if __name__ == "__main__":
    analyze_failures(sys.argv[1])
