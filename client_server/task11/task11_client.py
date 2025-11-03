import socket
import sys

# Check command-line arguments
if len(sys.argv) < 4:
    print("Usage: python3 task11_client.py host port output.txt")
    sys.exit(1)

host = sys.argv[1]
port = int(sys.argv[2])
outfile = sys.argv[3]

# Create a TCP socket (IPv4)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect to the Ruby server (Task 10)
s.connect((host, port))

# Send command to request a quote
s.sendall(b'QUOTE\n')

# Receive response from server (up to 4096 bytes)
resp = s.recv(4096).decode().strip()

# Write the server's reply to a file instead of printing
with open(outfile, 'w', encoding='utf-8') as f:
    f.write(resp + "\n")

print(f"Server reply saved to {outfile}")

# Close the connection
s.close()

