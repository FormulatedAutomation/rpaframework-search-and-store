def parse_tabular_data(text_to_parse):
    if text_to_parse is '':
        return ''
    split_data = text_to_parse.split('\n')
    try:
        return split_data[1]
    except IndexError:
        return ''
