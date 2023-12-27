using javax.xml.transform.stream;
using net.sf.saxon.s9api;
using JavaStringReader = java.io.StringReader;

namespace XsltTransformer
{
	public class XsltTransformer : IXsltTransformer
	{
		public string Transform(string xsl, string xml)
		{
			var xslInput = new StreamSource(new JavaStringReader(xsl));
			var xmlInput = new StreamSource(new JavaStringReader(xml));

			var processor = new Processor(false);
			var xsltCompiler = processor.newXsltCompiler();
			var compiledXsl = xsltCompiler.compile(xslInput).load30();
			var result = new XdmDestination();

			compiledXsl.transform(xmlInput, result);

			return result.getXdmNode().toString();
		}
	}
}
