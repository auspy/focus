import TopPoints from "../TopPoints";
import BotImage from "./BotImage";
import HeroButton from "./HeroButton";
import { BotImageServer, BotImageServerDark } from "./BotImageServer";

export default function Hero() {
  return (
    <div className="flex wrapper flex-col-reverse md:flex-row gap-8 items-start py-8 md:py-32 justify-between">
      <div className=" flex flex-col items-start  lg:w-[50vw] ">
        <h1 className="mb-3 md:mb-6 text-left normal-case">
          ADHD-Friendly Timer, <span className="">One Task at a Time</span>
        </h1>
        <div className=" text-left mb-5 md:mb-10 flex flex-col items-start gap-1   w-full md:max-w-[85%]">
          <p className="text-base">
            Time slipping away? Tasks piling up? Getting distracted? FocusMode
            is your <strong>personal productivity superhero</strong>, designed
            specifically for the ADHD minds.
          </p>
          <p className="text-base">
            Focus on one task at a time with an always-visible timer.{" "}
          </p>
        </div>
        <TopPoints
          labels={["Designed for ADHD", "Beat procrastination", "Stay focused"]}
        />
        <HeroButton
          href={process.env.NEXT_PUBLIC_DOWNLOAD_URL}
          label="Start Focusing"
          className="mt-3"
        />
        <p className="text-xs opacity-60 mt-2">
          Available for macOS. Windows & Linux coming soon
        </p>
      </div>
      <HeroVideo />
    </div>
  );
}

const HeroVideo = () => {
  return (
    <div className="relative w-fit h-fit bg-gray-50 overflow-hidden border border-zinc-200 rounded-lg">
      <video
        height={1080}
        width={1920}
        title={"Hero Video"}
        className={"relative  object-cover w-[800px] h-full"}
        src={"/hero.mp4"}
        loop
        autoPlay={true}
        muted
        playsInline
      />
    </div>
  );
};
