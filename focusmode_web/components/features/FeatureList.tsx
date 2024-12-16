import FeatureListItem from "./FeatureListItem";

export default function FeatureList() {
  const data = [
    {
      title: "Always visible without getting in the way",
      description: (
        <>
          <p>
            Our floating focus timer was specifically designed for people with
            ADHD symptoms who struggle with time blindness.
          </p>
          <p>
            Unlike traditional timers that get buried under windows, our
            always-visible companion stays gently present. It works with your
            ADHD attention patterns, keeping you connected to reality without
            adding to the noise.
          </p>
          <p className="italic opacity-70">
            Users save 8-10 hours weekly by staying focused and breaking free
            from time blindness.
          </p>
        </>
      ),
      imageUrl: "/follow.mp4",
      imageAlt: "ADHD Focus Timer",
      imagePosition: "left",
      className: "object-center",
      textColor: "text-zinc-800",
    },
    {
      title: "One thing. That's it. No overwhelm.",
      description: (
        <>
          <p>
            Our smart task system breaks through the barrier of distractions by
            showing you just one task at a time – the only one your ADHD brain
            needs to focus on right now.
          </p>
          <p>
            Unlike standard todo apps that bombard you with endless lists, our
            system gently guides you through your day, working in harmony with
            your natural attention patterns.
          </p>
          <p className="italic opacity-70">
            Users report completing 70% more tasks with our single-focus
            approach, breaking down complex projects into simple steps.
          </p>
        </>
      ),
      imageUrl: "/reorder.mp4",
      imageAlt: "ADHD Task Management",
      imagePosition: "right",
      textColor: "text-zinc-800",
      className: "object-bottom",
      gradientPosition: "top-0 left-0 ",
    },
    {
      title: "Watch your progress grow with calm animations",
      description: (
        <>
          <p>
            Keep track of your progress with gentle, unobtrusive animations that
            flow naturally in the background. Our subtle visual feedback stays
            out of your way while you work.
          </p>
          <p>
            Watch your focus sessions grow quietly with soothing animations that
            never distract. The calm visuals help you stay aware of your
            progress without breaking your flow.
          </p>
          <p className="italic opacity-70">
            Users report 3x higher motivation with our visual feedback system,
            turning challenging tasks into rewarding accomplishments.
          </p>
        </>
      ),
      className: "object-contain w-full",
      imageUrl: "/track-progress.mp4",
      imageAlt: "ADHD Progress Tracking",
      imagePosition: "left",
      textColor: "text-zinc-800",
    },
  ];
  return (
    <>
      <div className="wrapper flex flex-col gap-y-32 pb-20">
        {data.map((item, i) => (
          <FeatureListItem
            key={item.title + i}
            isImageLeft={item.imagePosition === "left"}
            {...item}
          />
        ))}
      </div>
    </>
  );
}
