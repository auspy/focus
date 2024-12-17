import EmailWaitlist from "@/components/homePage/EmailWaitlist";

function CTASection() {
  return (
    <section className="w-screen bg-gray-50 py-24 px-4">
      <div className=" contain mx-auto text-center space-y-8">
        <h2
          className="text-4xl md:text-5xl font-bold max-w-2xl mx-auto"
          style={{
            lineHeight: "1.2",
          }}
        >
          Looks like you are ready to get started with FocusMode.
        </h2>
        <div className="flex flex-col items-center justify-center">
          <EmailWaitlist />
        </div>
      </div>
    </section>
  );
}

export default CTASection;
