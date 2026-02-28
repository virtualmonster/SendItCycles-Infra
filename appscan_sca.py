import argparse
import subprocess
import sys
import time

APPSCAN = "appscan" if sys.platform == "win32" else "appscan.sh"


def api_login(api_key_id, api_key_secret):
    result = subprocess.run(
        f"{APPSCAN} api_login -u {api_key_id} -P {api_key_secret}",
        capture_output=True,
        text=True,
        shell=True,
    )
    return "Authenticated successfully" in result.stdout


def queue_analysis(app_id):
    result = subprocess.run(
        f"{APPSCAN} queue_analysis -a {app_id} -f sca.irx",
        capture_output=True,
        text=True,
        shell=True,
    )
    scan_id = result.stdout.strip().splitlines()[-1]
    return scan_id


def poll_status(scan_id, timeout=3600, interval=15):
    start = time.time()
    while True:
        result = subprocess.run(
            f"{APPSCAN} status -i {scan_id}",
            capture_output=True,
            text=True,
            shell=True,
        )
        output = result.stdout.strip()
        print("Waiting for scan to complete...")
        print(f"Status: {output}")
        if "Ready" in output:
            return True
        if "Failed" in output:
            return False
        if time.time() - start >= timeout:
            raise TimeoutError(f"Scan {scan_id} did not complete within {timeout} seconds")
        time.sleep(interval)


def get_report(scan_id):
    result = subprocess.run(
        f"{APPSCAN} get_report -i {scan_id} -s SCAN -t ISSUES -d appscan_sca_report.json",
        capture_output=True,
        text=True,
        shell=True,
    )
    return result.stdout, result.stderr


def prepare_sca():
    result = subprocess.run(
        f"{APPSCAN} prepare_sca -n sca.irx",
        capture_output=True,
        text=True,
        shell=True,
    )
    return result.stdout, result.stderr


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("api_key_id", help="API key ID")
    parser.add_argument("api_key_secret", help="API key secret")
    parser.add_argument("app_id", help="Application ID")
    parser.add_argument("--timeout", type=int, default=600, help="Scan timeout in seconds (default: 600)")
    return parser.parse_args()


def main():
    args = parse_args()
    api_key_id = args.api_key_id
    api_key_secret = args.api_key_secret
    app_id = args.app_id
    timeout = args.timeout

    print("Logging in...")
    if not api_login(api_key_id, api_key_secret):
        print("Authentication failed.")
        sys.exit(1)

    print("Preparing SCA...")
    stdout, stderr = prepare_sca()
    print(stdout)

    print("Queuing analysis...")
    scan_id = queue_analysis(app_id)
    print(f"Scan ID: {scan_id}")

    scan_ready = poll_status(scan_id, timeout=timeout)
    if not scan_ready:
        print("Scan failed.")
        sys.exit(1)

    print("Retrieving report...")
    stdout, stderr = get_report(scan_id)
    print(stdout)

    print("Scan complete. Report saved to appscan_sca_report.json.")


if __name__ == "__main__":
    try:
        main()
    except TimeoutError as e:
        print(f"Scan timed out: {e}")
