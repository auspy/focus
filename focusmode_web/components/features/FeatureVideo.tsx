"use client";
import { useEffect, useRef } from "react";

export default function FeatureVideo({
  src,
  className,
  gradientPosition,
  height,
  width,
  ...props
}) {
  const videoId = src.split(".")[0]; // Extract the video ID from the file name
  const videoRef = useRef(null);

  useEffect(() => {
    if (!videoRef.current) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          videoRef.current.play();
        } else {
          videoRef.current.pause();
        }
      },
      { threshold: 0.5 }
    );

    observer.observe(videoRef.current);

    return () => {
      if (videoRef.current) {
        observer.unobserve(videoRef.current);
      }
    };
  }, []);

  if (!src) return null;

  return (
    <div className="relative w-full max-h-[240px] md:max-h-[400px] h-fit bg-gray-50 overflow-hidden border border-zinc-200 rounded-lg">
      <video
        ref={videoRef}
        id={videoId}
        height={height}
        width={width}
        title={src}
        className={"relative  object-cover w-full h-full" + className}
        src={"/features/" + src}
        loop
        muted
        playsInline
        {...props}
      />
      <div
        className={`absolute ${
          gradientPosition || ""
        } w-full h-1/2 from-white to-transparent`}
      />
    </div>
  );
}
