import FeatureListItem from "./FeatureListItem";

export default function FeatureList() {
  const data = [
    {
      title: "Focus Mode Timer: Built for ADHD Minds",
      description: (
        <>
          <p>
            Living with ADHD means time can slip through your fingers like
            water. Our floating focus timer was specifically designed for people
            with ADHD symptoms who struggle with time blindness.
          </p>
          <p>
            Unlike traditional timers that get buried under windows, our
            always-visible companion stays gently present. It works with your
            ADHD attention patterns, keeping you connected to reality without
            adding to the noise.
          </p>
          <p>
            Our users report saving 8-10 hours weekly by staying in focus mode,
            finally breaking free from the cycle of time blindness that comes
            with hyperactivity disorder.
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
      title: "Smart Task Management: Break Free from Procrastination",
      description: (
        <>
          <p>
            With ADHD, starting tasks feels like pushing a boulder uphill. Our
            smart task system breaks through this barrier by showing you just
            one task at a time – the only one your ADHD brain needs to focus on
            right now.
          </p>
          <p>
            Unlike standard todo apps that bombard you with endless lists, our
            system gently guides you through your day, working in harmony with
            your natural attention patterns.
          </p>
          <p>
            Our users with hyperactivity disorder report completing 70% more
            tasks when they can focus on one thing at a time. Transform
            overwhelming projects into manageable steps.
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
      title: "Visual Progress Tracking: Celebrate Every ADHD Victory",
      description: (
        <>
          <p>
            When you have ADHD, maintaining motivation feels like trying to fill
            a leaky bucket. Our visual celebration system turns every completed
            task into a moment of triumph, feeding your brain's need for
            immediate rewards.
          </p>
          <p>
            Understanding ADHD symptoms means knowing the power of visible
            progress. Watch as your focus sessions stack up into beautiful
            achievement streaks with satisfying animations.
          </p>
          <p>
            Users with hyperactivity disorder report feeling 3x more motivated
            with our reward system. Transform your relationship with tasks from
            dread to excitement.
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
