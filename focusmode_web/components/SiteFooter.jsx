import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="border-t w-screen bg-gray-50">
      <div className="max-w-7xl contain mx-auto px-4 py-6 flex justify-between items-center">
        <div className="text-sm text-gray-600">
          © {new Date().getFullYear()} FocusMode
        </div>
        <nav>
          <ul className="flex items-center space-x-6 text-sm">
            <li>
              <Link
                href="#features"
                className="text-gray-600 hover:text-gray-900"
              >
                Features
              </Link>
            </li>
            {/* <li>
              <Link href="/pricing" className="text-gray-600 hover:text-gray-900">
                Pricing
              </Link>
            </li>
            <li>
              <Link href="/privacy" className="text-gray-600 hover:text-gray-900">
                Privacy
              </Link>
            </li> */}
            <li>
              <Link href="/terms" className="text-gray-600 hover:text-gray-900">
                Terms
              </Link>
            </li>
          </ul>
        </nav>
      </div>
    </footer>
  );
}

export default SiteFooter;
