import Logo from "@/components/Logo";
import { SignedOut } from "@clerk/nextjs";
import { SignedIn } from "@clerk/nextjs";
import { SignInButton, UserButton } from "@clerk/nextjs";
import Link from "next/link";

const Navigation = [
  // {
  //   label: "Request A Feature",
  //   href: "https://insigh.to/b/vizolv",
  //   rel: "noopener noreferrer",
  //   target: "_blank",
  // },
  {
    label: "Privacy Policy",
    href: "/privacy",
  },
];
export default function Header() {
  return (
    <div className="w-screen border-b border-border flex  justify-center">
      <div className="h-[60px] contain flex justify-between items-center  w-full">
        <div className="flex ">
          <Logo />
          <p className="ml-1 mb-1 text-[10px] opacity-60 font-medium self-end">
            BETA
          </p>
        </div>
        <div className="flex items-center gap-5">
          <div className="hidden md:flex  items-center gap-5">
            {Navigation.map(({ href, label, ...props }, index) => (
              <Link key={index} href={href} {...props}>
                {label}
              </Link>
            ))}
          </div>
          {/* <SignedOut>
            <SignInButton mode="modal">
              <button className="bg-zinc-800 rounded-[5px] py-[7px] p-2  button">
                Login
              </button>
            </SignInButton>
          </SignedOut>
          <SignedIn>
            <UserButton />
          </SignedIn> */}
        </div>
      </div>
    </div>
  );
}
