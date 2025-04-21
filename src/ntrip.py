import socket, threading, base64

#str2str -in serial://ttyACM0:115200:8:n:1#ubx -out tcpsvr://:5016#rtcm3 -msg '1004,1005(10),1006,1008(10),1012,1019,1020,1033(10),1042,1045,1046,1077,1087,1097,1107,1127,1230' -p 20.9965034 105.8034220 36.40

CASTER_IP = "0.0.0.0"         # Listen on all interfaces
CASTER_PORT = 2101            # Standard NTRIP port
MOUNTPOINT = "/RTK"         # Mountpoint for RTCM3 stream
USERNAME = "user"        # Replace with your desired username
PASSWORD = "pass"
clients = []

def handle_client(client_socket):
    try:
        request = client_socket.recv(1024).decode()
        print(f"Received request:\n{request}")

        # Parse headers
        headers = {}
        for line in request.split("\r\n"):
            if ": " in line:
                key, value = line.split(": ", 1)
                headers[key] = value

        # Check if the request contains the correct mountpoint
        if MOUNTPOINT not in request:
            response = "HTTP/1.1 404 Not Found\r\n\r\n"
            client_socket.send(response.encode())
            client_socket.close()
            return
        auth_header = headers.get("Authorization", "")

        if not auth_header.startswith("Basic "):
            response = "HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm=\"NTRIP Caster\"\r\n\r\n"
            client_socket.send(response.encode())
            client_socket.close()
            return

        # Decode and verify credentials
        credentials = base64.b64decode(auth_header[6:]).decode()
        username, password = credentials.split(":", 1)
        if username != USERNAME or password != PASSWORD:
            response = "HTTP/1.1 401 Unauthorized\r\nWWW-Authenticate: Basic realm=\"NTRIP Caster\"\r\n\r\n"
            client_socket.send(response.encode())
            client_socket.close()
            return

        # Send HTTP OK response
        response = (
            "ICY 200 OK\r\n"
            "Content-Type: application/octet-stream\r\n"
            "\r\n"
        )
        client_socket.send(response.encode())
        clients.append(client_socket)
        print(f"NTRIP Client connected: {client_socket.getpeername()}")
        while True:
            pass  # RTCM3 data will be sent by the broadcaster

    except Exception as e:
        print(f"Error handling client: {e}")
    finally:
        # Remove client from the list and close the connection
        if client_socket in clients:
            clients.remove(client_socket)
        client_socket.close()
        print("NTRIP Client disconnected!")

def broadcast_rtcm_data(rtcm_data):
    for client in clients[:]:
        try:
            client.sendall(rtcm_data)
        except Exception as e:
            print(f"Error sending data to NTRIP client: {e}")
            if client in clients:
                clients.remove(client)

def start_ntrip_caster():
    ntrip_server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ntrip_server.bind((CASTER_IP, CASTER_PORT))
    ntrip_server.listen(5)
    print(f"NTRIP caster started on {CASTER_IP}:{CASTER_PORT}")

    while True:
        client_socket, client_address = ntrip_server.accept()
        print(f"New NTRIP client connection from {client_address}")
        client_thread = threading.Thread(target=handle_client, args=(client_socket,))
        client_thread.start()

def tcp_client():
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect(("127.0.0.1", 5016))
    while True:
        data = client_socket.recv(1024)
        if not data:
            print("No more data from server.")
            break
        print(f"Data: {data.hex()}")
        broadcast_rtcm_data(data)

if __name__ == "__main__":
    tcp_thread = threading.Thread(target=tcp_client)
    tcp_thread.start()

    caster_thread = threading.Thread(target=start_ntrip_caster)
    caster_thread.start()
