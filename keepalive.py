import asyncio
import aiohttp
import socket

# List of TCP and UDP targets
TCP_TARGETS = [
    ("chat.freenode.net", 6667),  # Freenode IRC (Idle connections allowed)
    ("irc.oftc.net", 6667),  # OFTC IRC (Idle connections allowed)
    ("www.google.com", 443),  # Google TLS service
    ("8.8.8.8", 853),  # Google DNS-over-TLS
    ("cloudflare.com", 443),  # Cloudflare website
    # ("myvps.com", 22),
]

UDP_TARGETS = [
    ("1.1.1.1", 53),  # Cloudflare DNS
    ("8.8.8.8", 53),  # Google DNS
    ("ntp.ubuntu.com", 123),  # Ubuntu public NTP server
    ("time.google.com", 123),  # Google NTP server
]

PING_TARGETS = [
    "1.1.1.1",  # Cloudflare
    "8.8.8.8",  # Google DNS
    "9.9.9.9",  # Quad9 DNS
    "208.67.222.222",  # OpenDNS
]

async def keep_alive_tcp(host, port):
    """Keep a TCP connection alive by sending periodic messages."""
    while True:
        try:
            reader, writer = await asyncio.open_connection(host, port)
            print(f"Connected to {host}:{port}")

            while True:
                writer.write(b"keepalive\n")  # Dummy message
                await writer.drain()
                await asyncio.sleep(30)  # Send every 30 seconds

        except Exception as e:
            print(f"TCP error with {host}:{port}: {e}")
            await asyncio.sleep(5)  # Retry after 5 seconds

async def keep_alive_udp(host, port):
    """Send periodic UDP packets to keep NAT mappings active."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    while True:
        try:
            sock.sendto(b"keepalive", (host, port))
            print(f"Sent UDP packet to {host}:{port}")
        except Exception as e:
            print(f"UDP error with {host}:{port}: {e}")
        await asyncio.sleep(30)

async def keep_alive_ping(host):
    """Send periodic ICMP ping packets."""
    while True:
        try:
            proc = await asyncio.create_subprocess_exec(
                "ping", "-c", "1", "-W", "2", host,
                stdout=asyncio.subprocess.DEVNULL,
                stderr=asyncio.subprocess.DEVNULL
            )
            await proc.communicate()
            print(f"Pinged {host}")
        except Exception as e:
            print(f"Ping error with {host}: {e}")
        await asyncio.sleep(30)

async def keep_alive_http():
    """Send a periodic HTTP request to keep connections active."""
    async with aiohttp.ClientSession() as session:
        while True:
            try:
                async with session.get("https://example.com"):
                    print("Keep-alive HTTP request sent")
            except Exception as e:
                print(f"HTTP error: {e}")
            await asyncio.sleep(30)

async def main():
    tasks = (
        [keep_alive_tcp(host, port) for host, port in TCP_TARGETS] +
        [keep_alive_udp(host, port) for host, port in UDP_TARGETS] +
        [keep_alive_ping(host) for host in PING_TARGETS] +
        [keep_alive_http()]
    )
    await asyncio.gather(*tasks)

if __name__ == "__main__":
    asyncio.run(main())
