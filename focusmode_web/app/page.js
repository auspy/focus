import Header from "@/components/Header";
import Hero from "@/components/homePage/Hero";
import FeatureList from "@/components/features/FeatureList";

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
    </>
  );
}
