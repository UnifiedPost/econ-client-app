using javax.xml.transform.stream;
using net.sf.saxon.s9api;
using JavaStringReader = java.io.StringReader;

namespace XsltTransformer
{
	public class XsltTransformer : IXsltTransformer
	{
		public string Transform(string xsl, string xml, Dictionary<string, string>? parameters = null)
		{
			var xslInput = new StreamSource(new JavaStringReader(xsl));
			var xmlInput = new StreamSource(new JavaStringReader(xml));

			var processor = new Processor(false);
			var xsltCompiler = processor.newXsltCompiler();

			if (parameters is not null)
			foreach (var param in parameters)
			{
				xsltCompiler.setParameter(new QName(param.Key), new XdmAtomicValue(param.Value));
			}

			var compiledXsl = xsltCompiler.compile(xslInput).load30();
			var result = new XdmDestination();

			compiledXsl.transform(xmlInput, result);

			return result.getXdmNode().toString();
		}
	}
}
