import { alt } from "@/constants";
import Image from "next/image";

export default function Logo({ size = 28 }) {
  return (
    <Image
      className="flex-shrink-0 h-7 w-auto"
      style={{
        objectFit: "contain",
      }}
      src="/logo.svg"
      alt={alt}
      width={size}
      height={size}
    />
  );
}
