import FeatureVideo from "./FeatureVideo";

interface Props {
  title: string;
  description: string | JSX.Element;
  imageUrl: string;
  imageAlt: string;
  isImageLeft: boolean;
  textColor?: string;
  className?: string;
  gradientPosition?: string;
}
export default function FeatureListItem({
  isImageLeft,
  imageUrl,
  imageAlt,
  title,
  description,
  textColor,
  className,
  gradientPosition,
}: Props) {
  return (
    <>
      <div
        className={` w-full mx-auto flex flex-col  ${isImageLeft ? "lg:flex-row" : "lg:flex-row-reverse"}  items-start gap-6 md:gap-10 `}
      >
        <div className="w-full lg:w-1/2">
          <FeatureVideo
            gradientPosition={gradientPosition}
            className={className}
            src={imageUrl}
            title={imageAlt}
          />
        </div>
        <div className="w-full lg:w-1/2">
          <h2
            className={`mb-4 md:mb-6 md:text-4xl  font-extrabold leading-[1.2]  ${textColor || "text-text"}`}
          >
            {title}
          </h2>
          <div className="text-text flex flex-col items-start gap-2">
            {description}
          </div>
        </div>
      </div>
    </>
  );
}
