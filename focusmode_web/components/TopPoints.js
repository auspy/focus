import Image from "next/image";

const TopPoint = ({ label }) => {
  if (!label) {
    return null;
  }
  return (
    <div className="flex gap-1 items-center flex-row">
      <div className="border-2 bg-lightRed border-primary rounded-full relative p-1 h-3 w-3 ">
        <Image
          style={{
            objectFit: "contain",
          }}
          src="/tick.svg"
          alt="logo"
          fill="true"
        />
      </div>
      <div className="text-sm font-medium">{label}</div>
    </div>
  );
};
const TopPoints = ({ labels }) => {
  return (
    <div className="flex gap-2 flex-wrap items-center flex-row">
      {labels?.map((label, index) => (
        <TopPoint key={index} label={label} />
      ))}
    </div>
  );
};

export default TopPoints;
