import Header from "@/components/Header";
import Hero from "@/components/homePage/Hero";
import FeatureList from "@/components/features/FeatureList";
import TestimonialSection from "@/components/testimonials/TestimonialSection";
import CTASection from "@/components/CtaSection";
import SiteFooter from "@/components/SiteFooter";
export const revalidate = false;

export function generateStaticParams() {
  return [];
}

export default function Page() {
  return (
    <>
      <Header />
      <Hero />
      <FeatureList />
      <TestimonialSection />
      <CTASection />
      <SiteFooter />
    </>
  );
}
