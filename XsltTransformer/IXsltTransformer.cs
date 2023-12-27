namespace XsltTransformer
{
	public interface IXsltTransformer
	{
		string Transform(string xsl, string xml);
	}
}