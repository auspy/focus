"use client";
import Image from "next/image";
import Link from "next/link";

const PrimaryButton = ({ children, onClick, label, className, href }) => {
  const ButtonContent = () => (
    <>
      {children || label}
      {/* <Image src={"/logoWhite.svg"} alt="download" width={20} height={20} /> */}
    </>
  );

  const buttonClass =
    "bg-red px-[7vw] text-white font-semibold flex items-center gap-2 rounded-[5px] h-12 text-base " +
    className;

  if (href) {
    return (
      <Link href={href} className={buttonClass}>
        <ButtonContent />
      </Link>
    );
  }

  return (
    <button className={buttonClass} onClick={onClick}>
      <ButtonContent />
    </button>
  );
};

export default PrimaryButton;
