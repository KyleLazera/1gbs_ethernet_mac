from scapy.all import *  # Import everything
from scapy.layers.l2 import Ether  # Explicitly import Ether

iface = r"\Device\NPF_{592AAFFB-EC54-4197-B2B6-455DFB20A58D}"

# Message to repeat
base_message = "This is a testing packet of size 1500 bytes"

# Calculate how many times to repeat it to reach ~1492 bytes (Ethernet MTU - 8 byte header overhead)
repeat_count = 1492 // len(base_message)
payload = (base_message * repeat_count)[:1492]  # trim in case of rounding

#Pause Frame
pause_time = 1000  
pause_frame = Ether(dst="ff:ff:ff:ff:ff:ff", type=0x8808) / b'\x00\x01' / bytes([pause_time >> 8, pause_time & 0xFF])

# Build Ethernet packet
# packet = Ether(dst="ff:ff:ff:ff:ff:ff", type=0x1234) / payload.encode()
packet = Ether(dst="ff:ff:ff:ff:ff:ff", type=0x1234) / "This is a sample packet for testing."
packets = packet*10000

# Send the packet 
sendp(packets, iface=iface, verbose=False)
sendp(pause_frame, iface=iface, verbose=False)
sendp(packets, iface=iface, verbose=False)