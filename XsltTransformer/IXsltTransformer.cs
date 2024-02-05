namespace XsltTransformer
{
	public interface IXsltTransformer
	{
		string Transform(string xsl, string xml, Dictionary<string, string>? parameters = null);
	}
}